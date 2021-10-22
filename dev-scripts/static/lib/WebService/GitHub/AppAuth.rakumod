use OO::Monitors;
unit monitor WebService::GitHub::AppAuth;

use JSON::JWT;
use JSON::Fast;
use HTTP::UserAgent;

has $!app-id is built is required;
has $!pem is built;
has $!ua is built = HTTP::UserAgent.new;
has $!useragent is built = 'perl6-WebService-GitHub/0.1.0';

submethod TWEAK(IO::Path :$pem-file) {
    $!pem = $pem-file.slurp if $pem-file;
    die "Neither pem nor pem-file given" unless $!pem;
}

method !get-app-auth() {
    state $auth;
    state $timeout;
    if !$auth || DateTime.now > $timeout {
        $timeout = DateTime.now.later: :8minutes;
        my %payload =
            # issued at time, 60 seconds in the past to allow for clock drift
            iat => DateTime.now.posix - 60,
            # JWT expiration time (10 minute maximum)
            exp => DateTime.now.posix + 10 * 60,
            # GitHub App's identifier
            iss => $!app-id;
        my $encoded = JSON::JWT.encode(%payload, :alg("RS256"), :$!pem);
        $auth = "Bearer $encoded";
    }
    return $auth;
}

method list-installations() {
    my $resp = $!ua.get: "https://api.github.com/app/installations",
        User-Agent    => $!useragent,
        Authorization => self!get-app-auth(),
        Accept        => "application/vnd.github.v3+json",
    ;
    if $resp.is-success {
        return from-json($resp.content);
    }
}

method get-installation-token($inst-id) {
    state %cache;
    with %cache{$inst-id} -> $entr {
        if DateTime.now > $entr<timeout> {
            %cache{$inst-id}:delete;
        }
    }
    without %cache{$inst-id} {
        my $resp = $!ua.post: "https://api.github.com/app/installations/$inst-id/access_tokens", {},
            User-Agent    => $!useragent,
            Authorization => self!get-app-auth(),
            Accept        => "application/vnd.github.v3+json",
        ;
        if $resp.is-success {
            my $body = from-json($resp.content);
            %cache{$inst-id} = {
                token   => $body<token>,
                timeout => DateTime.new($body<expires_at>).earlier(:5minutes),
            };
        }
    }
    return %cache{$inst-id}<token>;
}


method get-installation-auth($inst-id) {
    "token " ~ self.get-installation-token($inst-id);
}

use OO::Monitors;
unit monitor WebService::GitHub::OAuth;

use JSON::JWT;
use JSON::Fast;
use HTTP::Tiny;
use URI::Escape;

has $!client-id is built is required;
has $!client-secret is built is required;
has $!redirect-url is built is required;
has $!allow-signups is built = False;
has $!pem is built;
has $!ht is built = HTTP::Tiny.new;
has $!useragent is built = 'perl6-WebService-GitHub/0.1.0';

# See https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-user-access-token-for-a-github-app#using-the-web-application-flow-to-generate-a-user-access-token

submethod TWEAK(IO::Path :$pem-file) {
    $!pem = $pem-file.slurp if $pem-file;
    die "Neither pem nor pem-file given" unless $!pem;
}

method step-two($step-one-state, $code, $state) {
    if $step-one-state ne $state {
        die "States don't match. Aborting.";
    }

    my $uri = "https://github.com/login/oauth/access_token"
        ~ "?client_id=" ~ uri-escape($!client-id)
        ~ "&client_secret=" ~ uri-escape($!client-secret)
        ~ "&code=" ~ uri-escape($code);
    my $resp = $!ht.post: $uri,
        headers => {
            User-Agent    => $!useragent,
            Accept        => "application/vnd.github.v3+json",
        }
    ;
    if $resp<success> {
        my $body = from-json($resp<content>.decode);
        return $body<token>;
    }
}


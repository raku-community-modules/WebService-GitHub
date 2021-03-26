use Test;
# -*- mode: perl6 -*-
use WebService::GitHub;
use WebService::GitHub::Users;

ok(1);
my $gh = WebService::GitHub.new;

if ((%*ENV<TRAVIS> && $gh.rate-limit-remaining()) || %*ENV<GH_TOKEN>) {
    diag "running on travis or with token";
    my $gh-user = WebService::GitHub::Users.new;
    my $user = $gh-user.show("JJ").data;
    my $userd = $gh.users.shoe("JJ").data;
    is $user<login>, 'JJ', 'User login OK';
    is $user<type>, 'User', 'User type OK';
    is $userd<login>, 'JJ', 'User login OK - from $gh.users';
    is $userd<type>, 'User', 'User type OK - from $gh.users';
}

done-testing();

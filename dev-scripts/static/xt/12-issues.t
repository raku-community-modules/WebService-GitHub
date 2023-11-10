use Test;
# -*- mode: perl6 -*-
use WebService::GitHub;
use WebService::GitHub::Issues;

ok(1);
my $github = WebService::GitHub.new;

if ((%*ENV<TRAVIS> && $github.rate-limit-remaining()) || %*ENV<GH_TOKEN>) {
    diag "running on travis or with token";
    my $gh = WebService::GitHub::Issues.new;
    my $issues = $gh.show(repo => 'raku-community-modules/WebService-GitHub').data;
    my $issuesd = $github.issues.show(repo => 'raku-community-modules/WebService-GitHub').data;
    cmp-ok $issues.elems, ">", 0, "Non-null number of issues";
    cmp-ok $issuesd.elems, ">", 0, "Non-null number of issues - from \$github.issues";
    my $first-issue = $gh.single-issue(repo => 'raku-community-modules/WebService-GitHub', issue => 1).data;
    my $first-issued = $github.issues.single-issue(repo => 'raku-community-modules/WebService-GitHub', issue => 1).data;
    is $first-issue<created_at>, "2015-10-26T19:45:45Z", "First issue OK";
    is $first-issued<created_at>, "2015-10-26T19:45:45Z", "First issue OK - from \$github.issues";
    my @all-issues = $gh.all-issues('JJ/perl6em');
    my @all-issuesd = $github.issues.all-issues('JJ/perl6em');
    cmp-ok @all-issues.elems, ">", 0, "Non-null number of issues";
    cmp-ok @all-issuesd.elems, ">", 0, "Non-null number of issues - from \$github.issues";
    is @all-issues[0]<state>, "closed", "State of first issue is closed";
    is @all-issuesd[0]<state>, "closed", "State of first issue is closed - from \$github.issues";
    cmp-ok +@all-issues.grep(*<state> eq 'closed'), ">=", 2, "More than 2 issues closed";
    cmp-ok +@all-issuesd.grep(*<state> eq 'closed'), ">=", 2, "More than 2 issues closed - from \$github.issues";
}

done-testing();

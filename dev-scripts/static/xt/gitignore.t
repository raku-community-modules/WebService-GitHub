use Test;

use WebService::GitHub::Gitignore;

my $gitignore = WebService::GitHub::Gitignore.new;

my @templates = $gitignore.get-all-templates.data;

# 2 Templates matches Perl
is @templates.grep(/Raku/).elems , 1 , "Gitignore templates";

my $raku-template = $gitignore.get-template("Raku").data;

ok $raku-template<source> ~~ /Raku/;

done-testing;

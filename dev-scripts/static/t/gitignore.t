use Test;

use WebService::GitHub::Gitignore;

my $gitignore = WebService::GitHub::Gitignore.new;

my @templates = $gitignore.get-all-templates.data;

# 2 Templates matches Perl
is @templates.grep(/Perl/).elems , 2 , "Gitignore templates";

my $raku-template = $gitignore.get-template("Perl6").data;

is $raku-template<source>, "# Gitignore for Perl 6 (http://www.perl6.org)\n# As part of https://github.com/github/gitignore\n\n# precompiled files\n.precomp\nlib/.precomp\n\n";

done-testing;

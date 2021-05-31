use Test;

use WebService::GitHub::Emojis;

my $g-emojis = WebService::GitHub::Emojis.new;

my @emojis = $g-emojis.get.data;

is @emojis.first(*.key eq "100").value, 'https://github.githubassets.com/images/icons/emoji/unicode/1f4af.png?v8';

done-testing;

use Test;
use WebService::GitHub::Licenses;

my $g-licenses = WebService::GitHub::Licenses.new;

my @licenses = $g-licenses.get-all-commonly-used.data;
ok(@licenses);

is @licenses.first(*<key> eq 'mit')<node_id>, 'MDc6TGljZW5zZTEz';

my $mit = $g-licenses.get("mit").data;

is $mit<url>,'https://api.github.com/licenses/mit';

my $repo-license = $g-licenses.get-for-repo('khalidelboray', 'zap-api-raku').data;

is $repo-license<license><key>, 'artistic-2.0';

done-testing;

use Test;
use WebService::GitHub::Pulls;

my $g-pulls = WebService::GitHub::Pulls.new;

my $p2 = $g-pulls.get('patrickbkr', 'GitHub-API-Testing', 2).data;
ok $p2;
is $p2<number>, 2;

dies-ok { $g-pulls.list('patrickbkr', 'GitHub-API-Testing', state => 'wrong-state') }, 'Passing a non allowed state errors';

my @pulls = $g-pulls.list('patrickbkr', 'GitHub-API-Testing', state => 'open').data;
ok @pulls, 'Requesting pulls with a valid state works.';
is @pulls.first(*<number> == 2)<node_id>, 'MDExOlB1bGxSZXF1ZXN0NjE2Nzg5MDQz', 'Requesting pulls with a valid state works.';

done-testing;

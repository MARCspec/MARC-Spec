use strict;
use warnings;
use v5.10.0;
use Test::More;
use Test::Exception;
use MARC::Spec;
use DDP class => { expand => 'all'};
use Benchmark;
my $t0 = Benchmark->new;
my $parser = MARC::Spec->new('...$a-z{LDR/0=\A|LDR/0=\X}{LDR/1!=\X}');
say ref $parser->subfields;
# checking field
ok $parser->field->tag eq '...', 'field tag';
ok $parser->field->indexStart == 0, 'field indexStart';
ok $parser->field->indexEnd eq '#', 'field indexEnd';
ok $parser->subfields->[0]->tag eq 'a', 'subfield a tag';
ok $parser->subfields->[1]->tag eq 'b', 'subfield a tag';

#checking subSpecs
ok scalar @{$parser->subfields->[0]->subSpecs} == 2, 'subbfield a subSpec count';
ok scalar @{$parser->subfields->[0]->subSpecs->[0]} == 2, 'subfield a subSpec count2';
ok scalar @{$parser->subfields->[1]->subSpecs} == 2, 'subfield b subSpec count';
ok scalar @{$parser->subfields->[1]->subSpecs->[0]} == 2, 'subfield b subSpec count2';

# ok $parser->field->subSpecs->[0]->[0]->operator eq '=', 'subSpec 1 tag';
# ok $parser->field->subSpecs->[0]->[0]->leftSubTerm->field->tag eq 'LDR', 'subSpec 1 left tag';
# ok $parser->field->subSpecs->[0]->[0]->leftSubTerm->field->charStart eq 0, 'subSpec 1 left charStart';
# ok $parser->field->subSpecs->[0]->[0]->leftSubTerm->field->charEnd eq 0, 'subSpec 1 left charEnd';
# ok $parser->field->subSpecs->[0]->[0]->leftSubTerm->field->charLength eq 1, 'subSpec 1 left charLength';
# ok $parser->field->subSpecs->[0]->[0]->rightSubTerm->raw eq 'A', 'subSpec 1 right raw';
# ok $parser->field->subSpecs->[1]->rightSubTerm->raw eq 'X', 'subSpec 3 right raw';
my $t1 = Benchmark->new;
my $td = timediff($t1, $t0);
print "the code took:",timestr($td),"\n";
done_testing();
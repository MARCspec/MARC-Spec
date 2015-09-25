use strict;
use warnings;
use v5.10.0;
use Test::More;
use Test::Exception;
use MARC::Spec;
use DDP class => { expand => 'all'};

#my $parser = MARC::Spec::Parser->new('245{$a}');
my $parser = MARC::Spec->new('245[0-3]/1-3{LDR/0=\A|LDR/0=\X}{LDR/1!=\X}');

# checking field
ok $parser->field->indexStart eq 0, 'field indexStart';
ok $parser->field->indexEnd eq 3, 'field indexEnd';
ok $parser->field->indexLength eq 4, 'field indexLength';
ok $parser->field->charStart eq 1, 'field charStart';
ok $parser->field->charEnd eq 3, 'field charEnd';
ok $parser->field->charLength eq 3, 'field charLength';

#checking subSpecs
ok scalar(grep {defined $_} @{$parser->field->subSpecs}) eq 2, 'field subSpec count';
ok scalar(grep {defined $_} @{@{$parser->field->subSpecs}[0]}) eq 2, 'field subSpec count2';

ok $parser->field->subSpecs->[0]->[0]->operator eq '=', 'subSpec 1 tag';
ok $parser->field->subSpecs->[0]->[0]->leftSubTerm->field->tag eq 'LDR', 'subSpec 1 left tag';
ok $parser->field->subSpecs->[0]->[0]->leftSubTerm->field->charStart eq 0, 'subSpec 1 left charStart';
ok $parser->field->subSpecs->[0]->[0]->leftSubTerm->field->charEnd eq 0, 'subSpec 1 left charEnd';
ok $parser->field->subSpecs->[0]->[0]->leftSubTerm->field->charLength eq 1, 'subSpec 1 left charLength';
ok $parser->field->subSpecs->[0]->[0]->rightSubTerm->raw eq 'A', 'subSpec 1 right raw';
ok $parser->field->subSpecs->[1]->rightSubTerm->raw eq 'X', 'subSpec 3 right raw';

done_testing();
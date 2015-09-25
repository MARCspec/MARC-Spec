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
#say ref $parser->subfields;
# checking field
ok $parser->field->tag eq '...', 'field tag';
ok $parser->field->indexStart == 0, 'field indexStart';
ok $parser->field->indexEnd eq '#', 'field indexEnd';
ok $parser->field->indexLength == -1, 'field indexLength';
ok $parser->subfields->[0]->code eq 'a-z', 'subfield code a';

#checking subSpecs
ok scalar @{$parser->subfields->[0]->subSpecs} == 2, 'subbfield a subSpec count';
ok scalar @{$parser->subfields->[0]->subSpecs->[0]} == 2, 'subfield a subSpec count2';
my $t1 = Benchmark->new;
my $td = timediff($t1, $t0);
print "the code took:",timestr($td),"\n";
done_testing();
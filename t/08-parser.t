use Test::More;
use MARC::Spec;
use DDP;

my $parser = MARC::Spec->parse('999$a[#]{245_01}{$a=\Foo|$a=\Y}');

#p $parser->subfields->[0]->subspecs;
#checking subspecs
ok scalar @{$parser->subfields->[0]->subspecs} == 2, 'subbfield a subspec count';
ok scalar @{$parser->subfields->[0]->subspecs->[1]} == 2, 'subfield a subspec count2';
done_testing();
use strict;
use Test::More;
use Test::Exception;
use MARC::Spec::ComparisonString;

my $cmp = MARC::Spec::ComparisonString->new('this\sis\sa\stest');
ok $cmp->raw eq 'this\sis\sa\stest', 'raw';
ok $cmp->comparable eq 'this is a test', 'comparable';

throws_ok {MARC::Spec::ComparisonString->new('this|is|wrong');} qr/^MARCspec ComparisonString exception.*/, 'MARCspec ComparisonString exception';
done_testing;
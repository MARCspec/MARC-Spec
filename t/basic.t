use strict;
use Test::More;
use MARC::Spec;
use MARC::Spec::Field;
use MARC::Spec::Subfield;
use MARC::Spec::ComparisonString;
use MARC::Spec::SubSpec;
use DDP;

BEGIN {
    use_ok 'MARC::Spec';
    use_ok 'MARC::Spec::Field';
    use_ok 'MARC::Spec::Subfield';
    use_ok 'MARC::Spec::ComparisonString';
    use_ok 'MARC::Spec::SubSpec';
 }

require_ok 'MARC::Spec';
require_ok 'MARC::Spec::Field';
require_ok 'MARC::Spec::Subfield';
require_ok 'MARC::Spec::ComparisonString';
require_ok 'MARC::Spec::SubSpec';

done_testing;

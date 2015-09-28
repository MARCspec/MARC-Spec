#requires 'perl', '5.008005';
requires 'perl', 'v5.10.0';

# requires 'Some::Module', 'VERSION';
 requires 'Moo';
 requires 'strictures';
 requires 'Carp';
 requires 'Const::Fast';
 requires 'Switch';

on test => sub {
    requires 'Test::More';
    requires 'Test::Exception';
};

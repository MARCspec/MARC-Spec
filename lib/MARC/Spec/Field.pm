package MARC::Spec::Field;

use strictures 2;
our $VERSION = '0.01';
use v5.10.0;
use Moo;
use namespace::clean;
extends 'MARC::Spec::Structure';

has indicator1 => (
    is => 'rw',
    required => 0
    );
    
has indicator2 => (
    is => 'rw',
    required => 0
    );
1;
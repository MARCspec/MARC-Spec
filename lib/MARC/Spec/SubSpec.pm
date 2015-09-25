package MARC::Spec::SubSpec;

use strictures 2;
our $VERSION = '0.01';
use Moo;
use namespace::clean;

has leftSubTerm => (
    is => 'rw',
    lazy => 1
    );
    
has rightSubTerm => (
    is => 'rw',
    lazy => 1
    );
    
has operator => (
    is => 'rw',
    lazy => 1,
    default => sub { "?" }
    );
1;
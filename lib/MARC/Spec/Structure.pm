package MARC::Spec::Structure;

use strictures 2;
our $VERSION = '0.01';
use Moo;
use namespace::clean;

has base => (
    is => 'ro',
    lazy => 1
    );
    
has indexStart => (
    is => 'ro',
    lazy => 1
    );

has indexEnd => (
    is => 'ro',
    lazy => 1
    );
    
has indexLength => (
    is => 'ro',
    lazy => 1
    );

has charStart => (
    is => 'ro',
    required => 0
    );

has charEnd => (
    is => 'ro',
    required => 0
    );

has charLength => (
    is => 'ro',
    required => 0
    );
    
has subSpecs => (
    is => 'ro',
    required => 0
    );
1;
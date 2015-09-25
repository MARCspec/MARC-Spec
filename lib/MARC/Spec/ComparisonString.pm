package MARC::Spec::ComparisonString;

use strictures 2;
our $VERSION = '0.01';
use warnings;
use Carp qw(croak);
use v5.10.0;
use Moo;
use namespace::clean;

has raw => (
    is => 'ro',
    required => 1
    );

has comparable => (
    is => 'ro',
    lazy => 1
    );

sub BUILDARGS {
   my ( $class, @args ) = @_;
   unshift @args, "raw" if @args % 2 == 1;
   return { @args };
}

sub BUILD {
    my ($self, $args) = @_;
    
    # char of list ${}!=~?|\s must be escaped if not at index 0*
    croak "MARCspec ComparisonString exception. Unescaped character detected. Tried to parse: ".$self->raw
        unless($self->raw =~ /^(.(?:[^\$\{\}\!\=\~\?\|\s]|(?<=\\\\)[\$\{\}\!\=\~\?\|])*)$/s);

    $self->{comparable} = $self->raw;
    my $replace = ' ';
    $self->{comparable} =~ s{\\s}{$replace}g;
    return;
}
1;
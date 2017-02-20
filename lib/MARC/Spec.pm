package MARC::Spec;

use Carp qw(croak);
use Moo;
use MARC::Spec::Parser;
use namespace::clean;

our $VERSION = '0.1.0';

has field => (
    is => 'rw',
    isa => sub {
        croak('Field is not an instance of MARC::Spec::Field')
            if(ref $_[0] ne 'MARC::Spec::Field')
    },
    required => 1
);

has subfields => (
    is => 'rwp',
    isa => sub {
        croak('Subfield is not an instance of MARC::Spec::Subfield.')
            if(grep {ref $_ ne 'MARC::Spec::Subfield'} @{$_[0]})
    },
    predicate => 1
);

sub BUILDARGS {
    my ($class, @args) = @_;
    if (@args % 2 == 1) { unshift @args, "field" }
    return { @args };
}

sub add_subfield {
    my ($self, $subfield) = @_;
    if(!$self->has_subfields) {
        $self->_set_subfields([$subfield]);
    } else {
        my @subfields = ( @{$self->subfields}, $subfield );
        $self->_set_subfields( \@subfields );
    }
}

sub add_subfields {
    my ($self, $subfields) = @_;
    if (ref $subfields ne 'ARRAY') { 
        croak('Subfields is not an ARRAYRef!')
    }
    if(!$self->has_subfields) {
        $self->_set_subfields($subfields);
    } else {
        my @merged = ( @{$self->subfields}, @{$subfields} );
        $self->_set_subfields( \@merged )
    }
}

sub parse {
    my ($self, $spec) = @_;
    my $parser = MARC::Spec::Parser->new($spec);
    return $parser->marcspec;
}

sub to_string {
    my ($self) = @_;
    my $string = $self->field->to_string();
    if($self->has_subfields) {
        foreach my $sf (@{$self->subfields}) {
            $string .= $sf->to_string()
        }
    }
    return $string;
}
1;
__END__

=encoding utf-8

=head1 NAME

L<MARC::Spec|MARC::Spec> - A MARCspec parser and builder

=head1 SYNOPSIS

    use MARC::Spec;
    
    # Parsing MARCspec from a string
    my $ms = MARC::Spec->parse('246[0-1]_16{007/0=\h}$f{245$h~\[microform\]|245$h~\microfilm}');

    # Structure
    say ref $ms;                                             # MARC::Spec
    say ref $ms->field;                                      # MARC::Spec::Field
    say ref $ms->field->subspecs;                            # ARRAY
    say ref $ms->field->subspecs->[0];                       # MARC::Spec::Subspec
    say ref $ms->field->subspecs->[0]->right;                # MARC::Spec
    say ref $ms->subfields;                                  # ARRAY
    say ref $ms->subfields->[0];                             # MARC::Spec::Subfield
    say ref $ms->subfields->[0]->subspecs;                   # ARRAY
    say ref $ms->subfields->[0]->subspecs->[0];              # ARRAY
    say ref $ms->subfields->[0]->subspecs->[0]->[1];         # MARC::Spec::Subspec
    say ref $ms->subfields->[0]->subspecs->[0]->[1]->left;   # MARC::Spec
    say ref $ms->subfields->[0]->subspecs->[0]->[1]->right;  # MARC::Spec::Comparisonstring

    # Access to attributes
    say $ms->field->base;                                                    # 246[0-1]_16
    say $ms->field->tag;                                                     # 246
    say $ms->field->index_start;                                             # 0
    say $ms->field->index_end;                                               # 1
    say $ms->field->index_length;                                            # 2
    say $ms->field->indicator1;                                              # 1
    say $ms->field->indicator2;                                              # 6
    say $ms->field->subspecs->[0]->subterms;                                 # '007/0=\h'
    say $ms->field->subspecs->[0]->left->field->tag;                         # 007
    say $ms->field->subspecs->[0]->left->field->char_start;                  # 0
    say $ms->field->subspecs->[0]->left->field->charEnd;                     # 0
    say $ms->field->subspecs->[0]->left->field->charPos;                     # 0
    say $ms->field->subspecs->[0]->left->field->char_length;                 # 1
    say $ms->field->subspecs->[0]->right->comparable;                        # 'h'
    say $ms->field->subspecs->[0]->operator;                                 # '='
    say $ms->subfields->[0]->base;                                           # 'f[0-#]'
    say $ms->subfields->[0]->code;                                           # 'f'
    say $ms->subfields->[0]->index_start;                                    # 0
    say $ms->subfields->[0]->index_end;                                      # '#'
    say $ms->subfields->[0]->subspecs->[0]->[0]->subterms;                   # '245$h~\[microform\]'
    say $ms->subfields->[0]->subspecs->[0]->[0]->left->field->tag;           # 245
    say $ms->subfields->[0]->subspecs->[0]->[0]->left->field->index_length;  # -1
    say $ms->subfields->[0]->subspecs->[0]->[0]->left->subfields->[0]->code; # 'h'
    say $ms->subfields->[0]->subspecs->[0]->[0]->right->comparable;          # '[microform]'
    say $ms->subfields->[0]->subspecs->[0]->[1]->right->comparable;          # 'microfilm'
    
    # creating MARCspec from scratch
    my $field    =  MARC::Spec::Field->new('245');
    my $subfield = MARC::Spec::Subfield->new('a');
    my $spec     = MARC::Spec->new($field);
    $spec->add_subfield($subfield);

=head1 DESCRIPTION

L<MARC::Spec|MARC::Spec> is a L<MARCspec - A common MARC record path language|http://marcspec.github.io/MARCspec/> parser and validator.

=head1 METHODS

=head2 new(MARC::Spec::Field)

Create a new MARC::Spec instance. Parameter must be an instance of L<MARC::Spec::Field|MARC::Spec::Field>.

=head2 parse(Str)

Parses a MARCspec as string and returns an instance of MARC::Spec.

=head2 add_subfield(MARC::Spec::Subfield)

Appends a subfield to the array of the attribute subfields. Parameter must be an instance of 
L<MARC::Spec::Subfield|MARC::Spec::Subfield>.

=head2 add_subfields(ArrayRef[MARC::Spec::Subfield])

Appends subfields to the array of the attribute subfields. Parameter must be an ArrayRef and 
elements must be instances of L<MARC::Spec::Subfield|MARC::Spec::Subfield>. 

=head1 PREDICATES

=head2 has_subfields

Returns true if attribute subfields has an value and false otherwise.

=head1 ATTRIBUTES

=head2 field

Obligatory. Attribute field is an instance of L<MARC::Spec::Field|MARC::Spec::Field>.
See L<MARC::Spec::Field|MARC::Spec::Field> for the description of attributes. 

=head2 subfields

If defined, subfields is an array of instances of L<MARC::Spec::Subfield|MARC::Spec::Subfield>.
See L<MARC::Spec::Subfield|MARC::Spec::Subfield> for the description of attributes.

=head1 AUTHOR

Carsten Klee C<< <klee at cpan.org> >>

=head1 CONTRIBUTORS

=over

=item * Johann Rolschewski, C<< <jorol at cpan> >>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Carsten Klee.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 BUGS

Please report any bugs to L<https://github.com/MARCspec/MARC-Spec/issues|https://github.com/MARCspec/MARC-Spec/issues>

=head1 SEE ALSO

L<MARC::Spec::Field|MARC::Spec::Field>,
L<MARC::Spec::Subfield|MARC::Spec::Subfield>,
L<MARC::Spec::Subspec|MARC::Spec::Subspec>,
L<MARC::Spec::Structure|MARC::Spec::Structure>,
L<MARC::Spec::Comparisonstring|MARC::Spec::Comparisonstring>,
L<MARC::Spec::Parser|MARC::Spec::Parser>

=cut

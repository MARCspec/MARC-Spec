# NAME

[MARC::Spec](https://metacpan.org/pod/MARC::Spec) - A MARCspec parser and builder

# SYNOPSIS

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

# DESCRIPTION

[MARC::Spec](https://metacpan.org/pod/MARC::Spec) is a [MARCspec - A common MARC record path language](http://marcspec.github.io/MARCspec/) parser and validator.

# METHODS

## new(MARC::Spec::Field)

Create a new MARC::Spec instance. Parameter must be an instance of [MARC::Spec::Field](https://metacpan.org/pod/MARC::Spec::Field).

## parse(Str)

Parses a MARCspec as string and returns an instance of MARC::Spec.

## add\_subfield(MARC::Spec::Subfield)

Appends a subfield to the array of the attribute subfields. Parameter must be an instance of 
[MARC::Spec::Subfield](https://metacpan.org/pod/MARC::Spec::Subfield).

## add\_subfields(ArrayRef\[MARC::Spec::Subfield\])

Appends subfields to the array of the attribute subfields. Parameter must be an ArrayRef and 
elements must be instances of [MARC::Spec::Subfield](https://metacpan.org/pod/MARC::Spec::Subfield). 

# PREDICATES

## has\_subfields

Returns true if attribute subfields has an value and false otherwise.

# ATTRIBUTES

## field

Obligatory. Attribute field is an instance of [MARC::Spec::Field](https://metacpan.org/pod/MARC::Spec::Field).
See [MARC::Spec::Field](https://metacpan.org/pod/MARC::Spec::Field) for the description of attributes. 

## subfields

If defined, subfields is an array of instances of [MARC::Spec::Subfield](https://metacpan.org/pod/MARC::Spec::Subfield).
See [MARC::Spec::Subfield](https://metacpan.org/pod/MARC::Spec::Subfield) for the description of attributes.

# AUTHOR

Carsten Klee `<klee at cpan.org>`

# CONTRIBUTORS

- Johann Rolschewski, `<jorol at cpan>`

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Carsten Klee.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# BUGS

Please report any bugs to [https://github.com/MARCspec/MARC-Spec/issues](https://github.com/MARCspec/MARC-Spec/issues)

# SEE ALSO

[MARC::Spec::Field](https://metacpan.org/pod/MARC::Spec::Field),
[MARC::Spec::Subfield](https://metacpan.org/pod/MARC::Spec::Subfield),
[MARC::Spec::Subspec](https://metacpan.org/pod/MARC::Spec::Subspec),
[MARC::Spec::Structure](https://metacpan.org/pod/MARC::Spec::Structure),
[MARC::Spec::Comparisonstring](https://metacpan.org/pod/MARC::Spec::Comparisonstring),
[MARC::Spec::Parser](https://metacpan.org/pod/MARC::Spec::Parser)

# NAME

MARC::Spec - A MARCspec Parser and validator

# SYNOPSIS

```perl
use MARC::Spec;

my $ms = MARC::Spec->new('246[0-1]_16{007/0=\h}$f{245$h~\[microform\]|245$h~\microfilm}');

# Structure
say ref $ms;                                                    # MARC::Spec
say ref $ms->field;                                             # MARC::Spec::Field
say ref $ms->field->subSpecs;                                   # ARRAY
say ref $ms->field->subSpecs->[0];                              # MARC::Spec::SubSpec
say ref $ms->field->subSpecs->[0]->rightSubTerm;                # MARC::Spec
say ref $ms->subfields;                                         # ARRAY
say ref $ms->subfields->[0];                                    # MARC::Spec::Subfield
say ref $ms->subfields->[0]->subSpecs;                          # ARRAY
say ref $ms->subfields->[0]->subSpecs->[0];                     # ARRAY
say ref $ms->subfields->[0]->subSpecs->[0]->[1];                # MARC::Spec::SubSpec
say ref $ms->subfields->[0]->subSpecs->[0]->[1]->leftSubTerm;   # MARC::Spec
say ref $ms->subfields->[0]->subSpecs->[0]->[1]->rightSubTerm;  # MARC::Spec::ComparisonString

# Access to attributes
say $ms->field->base;                                                           # 246[0-1]_16
say $ms->field->tag;                                                            # 246
say $ms->field->indexStart;                                                     # 0
say $ms->field->indexEnd;                                                       # 1
say $ms->field->indexLength;                                                    # 2
say $ms->field->indicator1;                                                     # 1
say $ms->field->indicator2;                                                     # 6
say $ms->field->subSpecs->[0]->subTermSet;                                      # '007/0=\h'
say $ms->field->subSpecs->[0]->leftSubTerm->field->tag;                         # 007
say $ms->field->subSpecs->[0]->leftSubTerm->field->charStart;                   # 0
say $ms->field->subSpecs->[0]->leftSubTerm->field->charEnd;                     # 0
say $ms->field->subSpecs->[0]->leftSubTerm->field->charLength;                  # 1
say $ms->field->subSpecs->[0]->rightSubTerm->comparable;                        # 'h'
say $ms->field->subSpecs->[0]->operator;                                        # '='
say $ms->subfields->[0]->base;                                                  # 'f[0-#]'
say $ms->subfields->[0]->tag;                                                   # 'f'
say $ms->subfields->[0]->indexStart;                                            # 0
say $ms->subfields->[0]->indexEnd;                                              # '#'
say $ms->subfields->[0]->subSpecs->[0]->[0]->subTermSet;                        # '245$h~\[microform\]'
say $ms->subfields->[0]->subSpecs->[0]->[0]->leftSubTerm->field->tag;           # 245
say $ms->subfields->[0]->subSpecs->[0]->[0]->leftSubTerm->field->indexLength;   # -1
say $ms->subfields->[0]->subSpecs->[0]->[0]->leftSubTerm->subfields->[0]->tag;  # 'h'
say $ms->subfields->[0]->subSpecs->[0]->[0]->rightSubTerm->comparable;          # '[microform]'
say $ms->subfields->[0]->subSpecs->[0]->[1]->rightSubTerm->comparable;          # 'microfilm'
```

# DESCRIPTION

MARC::Spec is a [MARCspec - A common MARC record path language](http://marcspec.github.io/MARCspec/marc-spec.html) parser and validator for Perl.

# AUTHOR

Carsten Klee &lt;kleetmp-github@yahoo.de&gt;

# COPYRIGHT

Copyright 2015- Carsten Klee

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

http://marcspec.github.io/MARCspec/marc-spec.html
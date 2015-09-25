# NAME

MARC::Spec - A MARCspec Parser and validator

# SYNOPSIS

```perl
use MARC::Spec;

my $ms = MARC::Spec->new('245{!$a}$b{007/0=\a|007/0=\t}');

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
say $ms->field->tag;                                                            # 245
say $ms->field->indexStart;                                                     # 0
say $ms->field->indexEnd;                                                       # '#'
say $ms->field->subSpecs->[0]->leftSubTerm->field->tag;                         # 245
say $ms->field->subSpecs->[0]->rightSubTerm->field->tag;                        # 245
say $ms->field->subSpecs->[0]->rightSubTerm->subfields->[0]->tag;               # 'a'
say $ms->field->subSpecs->[0]->operator;                                        # '!'
say $ms->subfields->[0]->tag;                                                   # 'b'
say $ms->subfields->[0]->indexStart;                                            # 0
say $ms->subfields->[0]->indexEnd;                                              # '#'
say $ms->subfields->[0]->subSpecs->[0]->[0]->leftSubTerm->field->tag;           # 007
say $ms->subfields->[0]->subSpecs->[0]->[0]->leftSubTerm->field->charStart;     # 0
say $ms->subfields->[0]->subSpecs->[0]->[0]->leftSubTerm->field->charEnd;       # 0
say $ms->subfields->[0]->subSpecs->[0]->[0]->rightSubTerm->comparable;          # 'a'
```

# DESCRIPTION

MARC::Spec is a MARCspec - A common MARC record path language](http://marcspec.github.io/MARCspec/marc-spec.html) parser and validator for Perl.

# AUTHOR

Carsten Klee &lt;kleetmp-github@yahoo.de&gt;

# COPYRIGHT

Copyright 2015- Carsten Klee

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

http://marcspec.github.io/MARCspec/marc-spec.html
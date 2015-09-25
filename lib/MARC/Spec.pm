package MARC::Spec;

use strictures 2;
our $VERSION = '0.01';
use Carp qw(croak);
use Const::Fast;
use Switch;
use Moo;
use MARC::Spec::Field;
use MARC::Spec::Subfield;
use MARC::Spec::ComparisonString;
use MARC::Spec::SubSpec;
use namespace::clean;

has spec => (
    is => 'ro',
    required => 1
    );

has parsed => (
    is => 'ro',
    required => 0
    );

has field => (
    is => 'ro',
    lazy => 1
    );

has subfields => (
    is => 'ro',
    required => 0
    );
    

const our $FIELDTAG => q{^(?<tag>(?:[a-z0-9\.]{3,3}|[A-Z0-9\.]{3,3}|[0-9\.]{3,3}))?};
const our $POSITIONORRANGE => q{(?:(?:(?:[0-9]+|#)\-(?:[0-9]+|#))|(?:[0-9]+|#))};
const our $INDEX => qq{(?:\\[(?<index>$POSITIONORRANGE)\\])?};
const our $CHARPOS => qq{\\/(?<charpos>$POSITIONORRANGE)};
const our $INDICATORS => q{_(?<indicators>(?:[_a-z0-9][_a-z0-9]{0,1}))};
const our $SUBSPECS => q{(?<subspecs>(?:\\{.+?(?<!(?<!(\$|\\\))(\$|\\\))\\})+)?};
const our $SUBFIELDS => q{(?<subfields>\$.+)?};
const our $FIELD => qq{(?<field>(?:$FIELDTAG$INDEX(?:$CHARPOS|$INDICATORS)?$SUBSPECS$SUBFIELDS))};
const our $SUBFIELDTAGRANGE => q{(?<subfieldtagrange>(?:[0-9a-z]\-[0-9a-z]))};
const our $SUBFIELDTAG => q{(?<tag>[\!-\?\[-\\{\\}-~])};
const our $SUBFIELD => q{(?<subfield>\$}.qq{(?:$SUBFIELDTAGRANGE|$SUBFIELDTAG)$INDEX(?:$CHARPOS)?$SUBSPECS)};
const our $LEFTSUBTERM => q{^(?<leftsubterm>(?:\\\(?:(?<=\\\)[\!\=\~\?]|[^\!\=\~\?])+)|(?:(?<=\$)[\!\=\~\?]|[^\!\=\~\?])+)?};
const our $OPERATOR => q{(?<operator>\!\=|\!\~|\=|\~|\!|\?)};
const our $SUBTERMS => qq{(?:$LEFTSUBTERM$OPERATOR)?(?<rightsubterm>.+)}.q{$};
const our $SUBSPEC => q{(?:\\{(.+?)\\})};

my $emitter = 'MARCspec Parser exception.';
my $hint = 'Tried to parse:';
my %cache;

sub BUILDARGS {
   my ( $class, @args ) = @_;
   unshift @args, "spec" if @args % 2 == 1;
   return { @args };
}

sub BUILD {
    my ($self, $args) = @_;
    $self->_matchField($self->spec);
    $self->_matchSubfields() if($self->parsed->{subfields});
    return;
}


sub _matchField {

    my $self = shift;
    
    _doChecks($self->spec,3);
    
    croak "$emitter Cannot detect fieldspec. $hint ".$self->spec
        unless($self->spec =~ /$FIELD/sg);

    %{$self->{parsed}} = %+; # matches als globale varibale

    croak "$emitter For fieldtag only '.', digits and lowercase alphabetic or digits and upper case alphabetics characters are allowed. $hint ".$self->spec
        if(!$self->parsed->{tag});
        
    croak "$emitter Detected useless data fragment or invalid field spec. $hint ".$self->spec
        if(length($self->parsed->{field}) != length($self->spec));
    
    # create a new Field
    $self->{field} = MARC::Spec::Field->new;
    
    # populate property %field 
    for my $fieldgroup (( 'tag','index','charpos','indicators')) { # iterate list
        if(defined $self->parsed->{$fieldgroup}) {
            if('indicators' eq $fieldgroup) {
                $self->field->{indicator1} = substr $self->parsed->{indicators}, 0, 1;
                $self->field->{indicator2} = substr $self->parsed->{indicators}, 1, 1
                    if(2 eq length($self->parsed->{indicators}));
            }
            elsif('index' eq $fieldgroup) {
                my @pos = _validatePos($self->parsed->{index});
                $self->field->{indexStart} = $pos[0];
                $self->field->{indexEnd} = $pos[1]
                    if defined $pos[1];
                
                my $indexLength = _calculateLength(@pos);
                $self->field->{indexLength} = $indexLength
                    if defined $indexLength;
                
            }
            elsif('charpos' eq $fieldgroup) {
                my @pos = _validatePos($self->parsed->{charpos});
                $self->field->{charStart} = $pos[0];
                $self->field->{charEnd} = $pos[1]
                    if defined $pos[1];
                
                my $charLength = _calculateLength(@pos);
                $self->field->{charLength} = $charLength
                    if defined $charLength;
            }
            else {
                $self->field->{$fieldgroup} = $self->parsed->{$fieldgroup}; # property field mit allen field groups füllen
            }
        }
    }

    if(defined $self->field->charStart) {
        croak "$emitter Either characterSpec or indicators are allowed. $hint ".$self->spec
            if(defined $self->field->indicator1 or defined $self->field->indicator2);

        croak "$emitter Either characterSpec for field or subfields are allowed. $hint ".$self->spec
            if(defined $self->parsed->{subfields});
    }
    
    unless(defined $self->field->indexStart) {
        $self->field->{indexStart} = 0;
        $self->field->{indexEnd} = '#';
    }

    # base is the context for abbreviated subspecs
    $self->field->{base} = _getBaseSpec($self->field);
    
    if($self->parsed->{subspecs}) {
        my @fieldSubSpecs = $self->_matchSubSpecs($self->parsed->{subspecs});
        foreach my $fieldSubSpec (@fieldSubSpecs) {
            # check if array length is above 1
            if(1 < scalar @{$fieldSubSpec}) {
                # alternatives to array (OR)
                my @or;
                foreach my $orSubSpec (@{$fieldSubSpec}) {
                    push @or, $self->_matchSubTerms($orSubSpec,[$self->field->base]);
                }
                push @{$self->field->{subSpecs}}, \@or;
            }
            else {
                push @{$self->field->{subSpecs}}, $self->_matchSubTerms($fieldSubSpec->[0],[$self->field->base]);
            }
        }
    }

    return;
}

sub _matchSubfields {

    my $self = shift;

    _doChecks($self->parsed->{subfields},2);

    my $i = 0;
    while($self->parsed->{subfields} =~ /$SUBFIELD/sg) {
    
        # handle subfield tag ranges
        if($+{subfieldtagrange}) {
            my $from = substr $+{subfieldtagrange},0,1;
            my $to = substr $+{subfieldtagrange},2,1;
            for my $tag ( $from..$to) {
                push @{$self->{subfields}}, $self->_createSubfield(matches => \%+, tag => $tag);
            }
        } else {
            push @{$self->{subfields}}, $self->_createSubfield(\%+);
        }
        $i++;
    }

    croak "$emitter Invalid subfield spec detected. $hint ".$self->parsed->{subfields}
        if(0 == $i);

    return;
}

sub _createSubfield {
    my ($self,%args) = @_;

    # create a new Subfield
    my $subfield = MARC::Spec::Subfield->new;
    my @pos;
    
    foreach my $key (keys %{$args{matches}}) {
        if('subfieldtagrange' eq $key) {
            $subfield->{tag} = $args{tag};
        } elsif('index' eq $key) {
            @pos = _validatePos($args{matches}{index});
            $subfield->{indexStart} = $pos[0];
            $subfield->{indexEnd} = $pos[1]
                if defined $pos[1];
            
            my $indexLength = _calculateLength(@pos);
            $subfield->{indexLength} = $indexLength
                if defined $indexLength;
        } elsif('charpos' eq $key) {
            @pos = _validatePos($args{matches}{charpos});
            $subfield->{charStart} = $pos[0];
            $subfield->{charEnd} = $pos[1]
                if defined $pos[1];
            
            my $charLength = _calculateLength(@pos);
            $subfield->{charLength} = $charLength
                if defined $charLength;
        } elsif('subspecs' ne $key) {
            $subfield->{$key} = $args{matches}{$key};
            
            # default for index
            unless(defined $subfield->indexStart) {
                $subfield->{indexStart} = 0;
                $subfield->{indexEnd} = '#';
            }
        }
    }
    
    $subfield->{base} = _getBaseSpec($subfield);
    # handle subspecs
    if(defined $args{matches}{subspecs}) {
        my @subfieldSubSpecs;
        
        croak "$emitter Invalid SubSpec detected. $hint". $args{matches}{subspecs}
            unless(@subfieldSubSpecs = $self->_matchSubSpecs($args{matches}{subspecs}));

        foreach my $subfieldSubSpec (@subfieldSubSpecs) {
            # check if array length is above 1
            if(1 < scalar @{$subfieldSubSpec}) {
                # alternatives to array (OR)
                my @or;
                foreach my $orSubSpec (@{$subfieldSubSpec}) {
                    push @or, $self->_matchSubTerms($orSubSpec,[$self->field->base,$subfield->base]);
                }
                push @{$subfield->{subSpecs}}, \@or;
            } else {
                push @{$subfield->{subSpecs}}, $self->_matchSubTerms($subfieldSubSpec->[0],[$self->field->base,$subfield->base]);
            }
        }
    }

    return $subfield;
    
}

sub _matchSubSpecs {

    my $self = shift;
    my $subSpecs = shift;
    
    my @_subSpecs;
    my @subSpecMatches;

    croak ("$emitter Assuming invalid spec. $hint $subSpecs")
        unless(@subSpecMatches = ($subSpecs =~ /$SUBSPEC/sg));

    foreach (@subSpecMatches) {
        push @_subSpecs, [split /(?<!\\)\|/];
    }

    return @_subSpecs;
}

sub _matchSubTerms {

    my ($self,$subTerms,$context_ref) = @_;
    
    croak "$emitter Unescaped character detected. $hint $subTerms"
        if($subTerms =~ /(?<![\\\\\$])[\{\}]/);

    croak "$emitter Assuming invalid spec. $hint $subTerms"
        unless($subTerms =~ /$SUBTERMS/sg);
    
    # create a new SubSpec
    my $subSpec = MARC::Spec::SubSpec->new;
    
    if(defined $+{leftsubterm}) {
        unless('\\' eq substr $+{leftsubterm},0,1) {
            my $left_spec = _buildSpec($+{leftsubterm},$context_ref);
            
            # this prevents the spec parsed again
            if($cache{$left_spec}) {
                $subSpec->{leftSubTerm} = $cache{$left_spec};
            } else {
                $subSpec->{leftSubTerm} = MARC::Spec->new($left_spec);
                $cache{$left_spec} = $subSpec->{leftSubTerm};
            }
        }
        else {
            $subSpec->{leftSubTerm} = MARC::Spec::ComparisonString->new(substr $+{leftsubterm},1);
        }
    }

    
    unless(defined $+{rightsubterm}) {
        croak "$emitter Right hand subTerm is missing. $hint $subTerms";
    }
    else {
        unless('\\' eq substr $+{rightsubterm},0,1) {
            my $right_spec = _buildSpec($+{rightsubterm},$context_ref);
            
            # this prevents the spec parsed again
            if($cache{$right_spec}) {
                $subSpec->{rightsubterm} = $cache{$right_spec};
            } else {
                $subSpec->{rightsubterm} = MARC::Spec->new($right_spec);
                $cache{$right_spec} = $subSpec->{rightsubterm};
            }
        }
        else {
            $subSpec->{rightSubTerm} = MARC::Spec::ComparisonString->new(substr $+{rightsubterm},1);
        }
        
    }
    
    $subSpec->{operator} = $+{operator} if defined $+{operator};
    
    return $subSpec;
}

sub _buildSpec {

    my ($spec, $context_ref) = @_;
    my $fieldContext = @$context_ref[0];
    my $subfieldContext = @$context_ref[1] if @$context_ref[1];
    my $fullcontext = join '',@$context_ref;
    
    return $spec if $spec eq $fullcontext;
    
    my $firstChar = substr $spec,0,1;
    switch($firstChar) {
        case '_'        {
                            my $refPos = index $fullcontext, $firstChar;
                            
                            if(0 <= $refPos) {
                                if('$' ne substr $fullcontext,$refPos - 1,1) {
                                   return substr($fullcontext,0,$refPos).$spec; # TODO: check if $refPos is valid length of substr
                                }
                            }
                            return $fullcontext.$spec;
                        }
                        
        case '$'        { return $fieldContext.$spec }
        
        case qr/\[|\//  {
                            my $refPos = rindex $fullcontext, $firstChar;
                        
                            if(0 <= $refPos) {
                                if('$' ne substr $fullcontext,$refPos - 1,1) {
                                    return substr($fullcontext,0,$refPos).$spec; # TODO: check if $refPos is valid length of substr
                                }
                            }
                            return $fullcontext.$spec;
                        }
                        
        else            { return $spec }
    
    }
}

sub _getBaseSpec {

    my $obj = shift;
    my $base = $obj->tag;
    my $indexStart = $obj->indexStart if defined $obj->indexStart;
    my $indexEnd = $obj->indexEnd if defined $obj->indexEnd;
    my ($charStart, $charEnd);
    
    $base .= '['.$indexStart;
       
    if($indexStart ne $indexEnd)
    {
        $base .= '-'.$indexEnd;
    }
    $base .= ']';
        
    if(defined $obj->charStart)
    {
        $charStart = $obj->charStart;
        $charEnd = $obj->charEnd;
        if($charStart eq 0 && $charEnd eq '#')
        {
            # use abbreviation
        }
        else
        {
            $base .= '/'.$charStart;
            if($charEnd ne $charStart)
            {
                $base .= '-'.$charEnd;
            }
        }
    }

    if($obj->can('indicator1'))
    {
        my $indicators = (defined $obj->indicator1) ? $obj->indicator1 : '_';
        $indicators   .= (defined $obj->indicator2) ? $obj->indicator2 : '';
        $base .= '_'.$indicators if($indicators ne '_');
    }

    return $base;
}

sub _validatePos {

    croak "$emitter Assuming index or character position or range. Only digits, the character # and one '-' is allowed. $hint ".$_[0]
        if($_[0] =~ /[^0-9\-#]/s);
    
    # something like 123- is not valid
    croak "$emitter Assuming index or character range. At least two digits or the character # must be present. $hint ".$_[0]
        if('-' eq substr $_[0], -1);
    
    # something like -123 is not valid
    croak "$emitter Assuming index or character position or range. First character must not be '-'. $hint ".$_[0]
        if('-' eq substr $_[0], 0,1);
    
    my @pos = split /\-/, $_[0], 2;

    # set end pos to start pos if no end pos
    push (@pos, $pos[0]) unless(defined $pos[1]);

    return @pos;
}

sub _calculateLength {

    # start eq end
    return 1 if $_[0] eq $_[1];
    # start = #, end != #
    return $_[1] + 1 if('#' eq $_[0] && '#' ne $_[1]);
    # start != #, end = #
    return undef if('#' ne $_[0] && '#' eq $_[1]);
    
    my $length = $_[1] - $_[0] + 1;
    
    croak "$emitter Ending character or index position must be equal or higher than starting character or index position."
        if(1 > $length);

    return $length;
}

sub _doChecks {

    croak "$emitter Argument must be of type SCALAR. $hint ".$_[0]
        unless(ref \$_[0] eq 'SCALAR');

    croak "$emitter Whitespaces are not allowed. $hint ".$_[0]
        if($_[0] =~ /\s/s);

    croak "$emitter Spec must be at least ".$_[1]." chracters long. $hint ".$_[0]
        unless($_[1] <= length($_[0]));
    
    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

L<MARC::Spec> - A MARCspec parser

=head1 SYNOPSIS

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
    say $ms->field->tag;                                                            # 246
    say $ms->field->indexStart;                                                     # 0
    say $ms->field->indexEnd;                                                       # 1
    say $ms->field->indexLength;                                                    # 2
    say $ms->field->indicator1;                                                     # 1
    say $ms->field->indicator2;                                                     # 6
    say $ms->field->subSpecs->[0]->leftSubTerm->field->tag;                         # 007
    say $ms->field->subSpecs->[0]->leftSubTerm->field->charStart;                   # 0
    say $ms->field->subSpecs->[0]->leftSubTerm->field->charEnd;                     # 0
    say $ms->field->subSpecs->[0]->leftSubTerm->field->charLength;                  # 1
    say $ms->field->subSpecs->[0]->rightSubTerm->comparable;                        # 'h'
    say $ms->field->subSpecs->[0]->operator;                                        # '='
    say $ms->subfields->[0]->tag;                                                   # 'f'
    say $ms->subfields->[0]->indexStart;                                            # 0
    say $ms->subfields->[0]->indexEnd;                                              # '#'
    say $ms->subfields->[0]->subSpecs->[0]->[0]->leftSubTerm->field->tag;           # 245
    say $ms->subfields->[0]->subSpecs->[0]->[0]->leftSubTerm->subfields->[0]->tag;  # 'h'
    say $ms->subfields->[0]->subSpecs->[0]->[0]->rightSubTerm->comparable;          # '[microform]'
    say $ms->subfields->[0]->subSpecs->[0]->[1]->rightSubTerm->comparable;          # 'microfilm'

=head1 DESCRIPTION

L<MARC::Spec> is a MARCspec - A common MARC record path language L<http://marcspec.github.io/MARCspec/marc-spec.html> parser and validator.

=head1 AUTHOR

Carsten Klee E<lt>kleetmp-github@yahoo.deE<gt>

=head1 COPYRIGHT

Copyright 2015- Carsten Klee

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut

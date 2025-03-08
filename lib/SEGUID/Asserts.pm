package SEGUID::Asserts;
use strict;
use warnings;
use Carp qw(croak);
use SEGUID::Manip qw(reverse);
use SEGUID::Alphabet qw(tablefactory);
use base 'Exporter';

our @EXPORT_OK = qw(assert_in_alphabet assert_alphabet assert_complementary);
our $VERSION = '1.02';

=head1 NAME

SEGUID::Asserts - Validation utilities for SEGUID sequence operations

=head1 SYNOPSIS

    use SEGUID::Asserts qw(assert_in_alphabet assert_complementary);
    
    assert_in_alphabet($sequence, \%alphabet);
    assert_complementary($watson, $crick, \%alphabet);

=cut

# Create valid character sets
my $VALID_CHARS = {
    map { $_ => 1 } 
    ('A'..'Z', 'a'..'z', '0'..'9', '-', "\n", ';')
};

sub assert_in_alphabet {
    my ($seq, $alphabet) = @_;
    
    # Type validation
    croak "Argument 'seq' must be a string" 
        unless defined $seq && !ref($seq);
    croak "Argument 'alphabet' must be a hashref" 
        unless defined $alphabet && ref($alphabet) eq 'HASH';
    croak "Argument 'alphabet' must not be empty" 
        unless %$alphabet;
        
    # Validate alphabet characters
    my @invalid = grep { !exists $VALID_CHARS->{$_} } keys %$alphabet;
    croak "Only A-Z a-z 0-9 -\\n; allowed. Invalid: @invalid" if @invalid;
    
    # Nothing to do for empty sequence
    return if length($seq) == 0;
    
    # Find unknown characters
    my %unknown;
    for my $c (split //, $seq) {
        $unknown{$c} = 1 unless exists $alphabet->{$c};
    }
    
    if (%unknown) {
        my $missing = join ' ', map { quotemeta($_) } sort keys %unknown;
        croak "Detected symbols $missing not in the 'alphabet'";
    }
}

sub assert_alphabet {
    my ($alphabet) = @_;
    
    croak "Argument 'alphabet' must be a hashref" 
        unless defined $alphabet && ref($alphabet) eq 'HASH';
    
    my %keys = map { $_ => 1 } keys %$alphabet;
    my %values;
    
    # Handle string values by splitting into characters
    for my $value (values %$alphabet) {
        if (!ref($value)) {
            map { $values{$_} = 1 } split //, $value;
        }
    }
    
    # Check for keys not in values
    my @unknown;
    for my $key (keys %keys) {
        push @unknown, $key unless exists $values{$key};
    }
    
    if (@unknown) {
        my $missing = join ' ', map { quotemeta($_) } sort @unknown;
        croak "Detected keys ($missing) in 'alphabet' that are not in the values";
    }
}

sub assert_complementary {
    my ($watson, $crick, $alphabet) = @_;
    
    # Get complementarity table
    my $tb = tablefactory($alphabet);
    my %keys = map { $_ => 1 } keys %$tb;
    
    # Validate alphabet
    my @values = values %$tb;
    croak "Was a single-stranded alphabet used by mistake? (values)"
        unless @values > 1;
    croak "Was a single-stranded alphabet used by mistake? (value length)"
        unless length($values[0]) == 1;
    
    assert_alphabet($tb);
    
    # Add gap character if not present
    unless (exists $tb->{'-'}) {
        $tb->{'-'} = '-';
        %keys = map { $_ => 1 } keys %$tb;
    }
    
    # Validate sequence lengths
    croak "Watson and Crick strands must be equal length"
        unless length($watson) == length($crick);
    
    # Validate sequences against alphabet
    assert_in_alphabet($watson, \%keys);
    assert_in_alphabet($crick, \%keys);
    

    
    # Check complementarity
    my $reversecrick = reverse($crick);
    
    for my $i (0..length($watson)-1) {
        my $w = substr($watson, $i, 1);
        my $c = substr($reversecrick, $i, 1);
        
        # Skip gaps
        next if $w eq '-' || $c eq '-';
        
        # Check complementarity
        my $valid_pairs = $tb->{$w};
        unless ($valid_pairs =~ /$c/) {
            croak sprintf(
                "Non-complementary basepair (%s,%s) detected at position %d",
                $w, $c, $i + 1
            );
        }
    }
}

1;

=head1 DESCRIPTION

This module asserts alphabet and complementarity.


=head1 AUTHOR

Gyorgy Babnigg <gbabnigg@gmail.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


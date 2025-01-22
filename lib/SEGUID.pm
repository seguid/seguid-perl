package SEGUID;
use strict;
use warnings;
use 5.010;
use Digest::SHA qw(sha1_base64);
use Carp qw(croak);
use base 'Exporter';
use SEGUID::Alphabet qw(tablefactory);
use SEGUID::Chksum qw(seguid lsseguid csseguid ldseguid cdseguid seguidv1 seguidv1urlsafe);

our $VERSION = '1.01';
our @EXPORT_OK = qw(
    seguid lsseguid csseguid ldseguid cdseguid 
    validate_sequence slurp
);

=head1 NAME

SEGUID - SEGUID checksums for linear, circular, single- and double-stranded sequences

=head1 SYNOPSIS

    use SEGUID qw(lsseguid csseguid ldseguid cdseguid seguid);
    
    # Linear single-stranded
    my $checksum1 = lsseguid($seq, alphabet => "{DNA}", form => "long");
    
    # Circular single-stranded
    my $checksum2 = csseguid($seq, alphabet => "{DNA}", form => "long");
    
    # Linear double-stranded
    my $checksum3 = ldseguid($watson, $crick, alphabet => "{DNA}", form => "long");
    
    # Circular double-stranded
    my $checksum4 = cdseguid($watson, $crick, alphabet => "{DNA}", form => "long");
    
    # Original SEGUID v1
    my $checksum5 = seguid($seq, alphabet => "{DNA}", form => "long");

=head1 DESCRIPTION

This package provides four functions, C<lsseguid()>, C<csseguid()>, C<ldseguid()>, and C<cdseguid()>
for calculating SEGUID v2 checksums, and one function, C<seguid()>, for calculating SEGUID v1 checksums.
SEGUID v2 is described in Pereira et al. (2024), and SEGUID v1 in Babnigg & Giometti (2006).

=head2 Function Types

    Topology    Strandedness    Function
    ========    ============    ========
    linear      single         lsseguid()
    circular    single         csseguid()
    linear      double         ldseguid()
    circular    double         cdseguid()

=head2 Function Arguments

=over 4

=item B<seq> (string)

The sequence for which the checksum should be calculated. The sequence may only comprise of symbols in the
alphabet specified by the alphabet argument.

=item B<watson, crick> (strings)

Two reverse-complementary DNA sequences. Both sequences should be specified in the 5'-to-3' direction.

=item B<alphabet> (string)

The type of sequence used. Options include:

=over 4

=item * C<{DNA}> (default) - DNA sequence

=item * C<{RNA}> - RNA sequence

=item * C<{protein}> - amino-acid sequence

=item * C<{DNA-extended}> or C<{RNA-extended}> - extended set including IUPAC symbols

=item * C<{protein-extended}> - extended amino-acid symbols

=item * Custom alphabets: e.g., "X,Y,Z" or "AT,CG" or "{DNA},XY"

=back

=item B<form> (string)

How the checksum is presented:

=over 4

=item * C<long> (default) - full-length checksum

=item * C<short> - six-digit checksum

=item * C<both> - returns both forms

=back

=back

=head2 Return Value

Returns a single string for "long" or "short" forms, or an array of two strings for "both" form.
Long checksums are 27 characters (without prefix). Short checksums are the first six characters.

=head1 Base64 and Base64url Encodings

The Base64url encoding used in SEGUID v2 replaces unsafe URL characters:
  + (plus) becomes - (minus)
  / (forward slash) becomes _ (underscore)

=head1 REFERENCES

=over 4

=item 1. Babnigg & Giometti (2006). doi:10.1002/pmic.200600032

=item 2. Pereira et al. (2024). doi:10.1101/2024.02.28.582384

=item 3. Josefsson (2006). RFC 4648. doi:10.17487/RFC4648

=back

=head1 AUTHOR

Gyorgy Babnigg <gbabnigg@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 by Gyorgy Babnigg

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# Regular expressions for sequence validation
our $VALID_SEQ_PATTERN = qr/^[A-Za-z*\s]+$/;
our $VALID_AA_PATTERN = qr/^[A-Za-z*\s]+$/;  # Amino acid sequence pattern
our $VALID_NA_PATTERN = qr/^[ACGTUacgtu\s]+$/;  # Nucleic acid sequence pattern

sub validate_sequence {
    my ($sequence, $type) = @_;
    $type //= 'generic';  # Default to generic sequence type
    
    $sequence =~ s/\s+//g;  # Remove whitespace
    
    my $pattern = $type eq 'aa' ? $VALID_AA_PATTERN :
                  $type eq 'na' ? $VALID_NA_PATTERN :
                                 $VALID_SEQ_PATTERN;
    
    return $sequence =~ $pattern;
}

sub slurp {
    my ($file) = @_;
    local $/;
    open my $fh, '<', $file or croak "Cannot open $file: $!";
    my $content = <$fh>;
    close $fh;
    return $content;
}

1;
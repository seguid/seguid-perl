package SEGUID::Chksum;
use strict;
use warnings;
use Carp qw(croak);
use Digest::SHA qw(sha1);
use MIME::Base64 qw(encode_base64url encode_base64);
use SEGUID::Manip qw(reverse rotate rotate_to_min min_rotation_perl min_rotation);
use SEGUID::Alphabet qw(tablefactory);
use SEGUID::Asserts qw(assert_in_alphabet assert_complementary);
use base 'Exporter';

our @EXPORT_OK = qw(seguid lsseguid csseguid ldseguid cdseguid seguidv1 seguidv1urlsafe);
our $VERSION = '1.01';

# Define prefixes
our $SEGUID_PREFIX   = 'seguid=';
our $LSSEGUID_PREFIX = 'lsseguid=';
our $CSSEGUID_PREFIX = 'csseguid=';
our $LDSEGUID_PREFIX = 'ldseguid=';
our $CDSEGUID_PREFIX = 'cdseguid=';

our $SEGUIDV1_PREFIX   = 'seguidv1=';
our $SEGUIDV1URLSAFE_PREFIX   = 'seguidv1urlsafe=';


our $B64ALPHABET = { map { $_ => 1 } split //, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/_-' };
our $SHORT = 6;

# Internal function for SEGUID generation
sub _seguid {
    my ($seq, $alphabet, $use_urlsafe) = @_;
    
    croak "A sequence must not be empty" unless $seq;
    
    # Get alphabet and validate sequence
    my $tb = tablefactory($alphabet);
    assert_in_alphabet($seq, { map { $_ => 1 } keys %$tb });
    
    # Generate SHA1 hash
    my $sha1 = sha1($seq);
    
    # Encode in base64
    my $encoded = $use_urlsafe ? 
        encode_base64url($sha1) :
        encode_base64($sha1, '');
    
    # Remove padding and validate
    $encoded =~ s/=+$//;
    
    croak "Invalid checksum length" unless length($encoded) == 27;
    for my $char (split //, $encoded) {
        croak "Invalid base64 character: $char" 
            unless exists $B64ALPHABET->{$char};
    }
    
    return $encoded;
}

# Internal function for SEGUID generation
sub _seguidv1 {
    my ($seq, $alphabet, $use_urlsafe) = @_;
    
    croak "A sequence must not be empty" unless $seq;
    
    # Convert to uppercase; remove invalid characters and accept only the 20 amino acids

    $seq =~ tr/[a-z]/[A-Z]/;
    $seq =~ s/[^ACDEFGHIKLMNPQRSTVWY]//g;

    croak "A protein sequence must not be empty" unless $seq;

    # Generate SHA1 hash
    my $sha1 = sha1($seq);
    
    # Encode in base64
    my $encoded = $use_urlsafe ? 
        encode_base64url($sha1) :
        encode_base64($sha1, '');
    
    # Remove padding and validate
    $encoded =~ s/=+$//;
    
    croak "Invalid checksum length" unless length($encoded) == 27;
    for my $char (split //, $encoded) {
        croak "Invalid base64 character: $char" 
            unless exists $B64ALPHABET->{$char};
    }
    
    return $encoded;
}

# Internal function for format handling
sub _form {
    my ($prefix, $csum, $form) = @_;
    
    if ($form eq 'both') {
        return (substr($csum, 0, $SHORT), $prefix . $csum);
    }
    elsif ($form eq 'long') {
        return $prefix . $csum;
    }
    elsif ($form eq 'short') {
        return substr($csum, 0, $SHORT);
    }
    else {
        croak "Invalid form: $form";
    }
}

=head1 NAME

SEGUID::Chksum - Generate SEGUID checksums for various DNA sequence types

=head1 SYNOPSIS

    use SEGUID::Chksum qw(seguid lsseguid csseguid ldseguid cdseguid seguidv1 seguidv1urlsafe);
    
    my $checksum = seguid("ACGT");
    my $safe_checksum = lsseguid("ACGT");
    my $circular = csseguid("ACGT");
    my $double = ldseguid("ACGT", "TGCA");
    my $circ_double = cdseguid("ACGT", "TGCA");

=cut

sub seguid {
    my ($seq, $alphabet, $form) = @_;
    $alphabet //= '{DNA}';
    $form //= 'long';
    
    return _form(
        $SEGUID_PREFIX,
        _seguid($seq, $alphabet, 0),
        $form
    );
}

sub seguidv1 {
    my ($seq, $alphabet, $form) = @_;
    $alphabet //= '{proteinV1}';
    $form //= 'long';
    
    return _form(
        $SEGUIDV1_PREFIX,
        _seguidv1($seq, $alphabet, 0),
        $form
    );
}

sub seguidv1urlsafe {
    my ($seq, $alphabet, $form) = @_;
    $alphabet //= '{proteinV1}';
    $form //= 'long';
    
    return _form(
        $SEGUIDV1URLSAFE_PREFIX,
        _seguidv1($seq, $alphabet, 1),
        $form
    );
}

sub lsseguid {
    my ($seq, $alphabet, $form) = @_;
    $alphabet //= '{DNA}';
    $form //= 'long';
    
    return _form(
        $LSSEGUID_PREFIX,
        _seguid($seq, $alphabet, 1),
        $form
    );
}

sub csseguid {
    my ($seq, $alphabet, $form) = @_;
    $alphabet //= '{DNA}';
    $form //= 'long';
    
    return _form(
        $CSSEGUID_PREFIX,
        _seguid(rotate_to_min($seq), $alphabet, 1),
        $form
    );
}

sub ldseguid {
    my ($watson, $crick, $alphabet, $form) = @_;
    $alphabet //= '{DNA}';
    $form //= 'long';
    
    croak "Watson sequence must not be empty" unless $watson;
    croak "Crick sequence must not be empty" unless $crick;
    croak "Sequences must be equal length" 
        unless (length($watson) == length($crick));
        
    assert_complementary($watson, $crick, $alphabet);
    
    my $tb = tablefactory($alphabet);
    croak "Was a single-stranded alphabet used by mistake?"
        unless scalar(keys %$tb) > 1;
    
    my $exalphabet = $alphabet . ',--,;;';
    
    # Create spec string based on lexicographic ordering
    my $spec = $watson lt $crick ? 
        $watson . ';' . $crick :
        $crick . ';' . $watson;
    
    return _form(
        $LDSEGUID_PREFIX,
        _seguid($spec, $exalphabet, 1),
        $form
    );
}

sub cdseguid {
    my ($watson, $crick, $alphabet, $form) = @_;
    $alphabet //= '{DNA}';
    $form //= 'long';
    

    # Check for empty sequences
    croak "Watson sequence must not be empty" unless $watson;
    croak "Crick sequence must not be empty" unless $crick;
    
    # Check for equal length
    unless (length($watson) == length($crick)) {croak "Sequences must be equal length! " };


    # assert complementarity
    assert_complementary($watson, $crick, $alphabet);

    # concatenating by TTTT
    my $concat_connector = "TTTT";
    my $concatenated = $watson . $concat_connector . $crick;

    my $min_rotation_concat = min_rotation($concatenated);

    # is the $min_rotation_concat in Watson or Crick?
    my ($w, $c, $ind, $swap);
    if($min_rotation_concat < length($watson)){
        # Watson
        $ind = $min_rotation_concat;
        $w = rotate($watson, $ind);
        $c = rotate($crick,  length($crick) - $ind);

    }else{
        # Crick
        $ind = $min_rotation_concat - length($watson) - length($concat_connector) ;
        $w = rotate($watson,  length($watson) - $ind);
        $c = rotate($crick, $ind);
        # should swap the two sequences
        $swap = $w;
        $w = $c;
        $c = $swap;
    }
   
    
    my $result = ldseguid($w, $c, $alphabet, 'long');
    return _form(
        $CDSEGUID_PREFIX,
        substr($result, length($LDSEGUID_PREFIX)),
        $form
    );
}

1;





=head1 DESCRIPTION

This module implements the SEGUID (Sequence Globally Unique IDentifier) 
algorithm for various types of DNA sequences. It supports:

=over 4

=item * Single-stranded linear DNA (seguid, lsseguid)

=item * Single-stranded circular DNA (csseguid)

=item * Double-stranded linear DNA (ldseguid)

=item * Double-stranded circular DNA (cdseguid)

=back

=head1 AUTHOR

Gyorgy Babnigg <gbabnigg@gmail.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

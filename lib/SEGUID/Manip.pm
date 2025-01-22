package SEGUID::Manip;

use strict;
use warnings;
use Carp qw(croak);
use SEGUID::DivSufSort::PP qw(min_rotation_divsufsort);
use base 'Exporter';
our @EXPORT_OK = qw(rotate reverse min_rotation_perl min_rotation rotate_to_min);


sub rotate {
    my ($seq, $amount) = @_;
    $amount //= 0;  # Default value if not provided

    croak "Argument 'seq' must be a string" unless defined $seq;
    croak "Argument 'amount' must be an integer" unless defined $amount && $amount =~ /^-?\d+$/;

    # Nothing to rotate?
    return $seq if length($seq) == 0;

    $amount = $amount % length($seq);

    # Rotate?
    if ($amount > 0) {
        return substr($seq, $amount) . substr($seq, 0, $amount);
    }
    return $seq;
}

sub reverse {
    my ($seq) = @_;
    croak "Argument 'seq' must be a string" unless defined $seq;
    return scalar reverse $seq;
}

sub min_rotation_perl {
    my ($s) = @_;
    croak "Argument must be a string" unless defined $s;

    my $prev = undef;
    my $rep = 0;
    my @ds = split //, ($s . $s);  # Perl equivalent of array("u", 2 * s)
    my $lens = length($s);
    my $lends = $lens * 2;
    my $old = 0;
    my $k = 0;
    my $w = "";

    while ($k < $lends) {
        my ($i, $j) = ($k, $k + 1);
        while ($j < $lends && $ds[$i] le $ds[$j]) {
            $i = ($ds[$i] eq $ds[$j]) ? $i + 1 : $k;
            $j++;
        }
        while ($k < $i + 1) {
            $k += $j - $i;
            $prev = $w;
            $w = join '', @ds[$old..($k-1)];
            $old = $k;
            if ($w eq $prev) {
                $rep++;
            }
            else {
                $prev = $w;
                $rep = 1;
            }
            if (length($w) * $rep == $lens) {
                return $old - $i;
            }
        }
    }
    return 0;
}

sub rotate_to_min {
    my ($s) = @_;
    
    # Ensure uppercase letters are ordered before lowercase letters
    die "ASCII ordering assumption violated" unless min_rotation_perl("Aa") == 0;
    
    my $amount = min_rotation_perl($s);
    return rotate($s, $amount);
}



*min_rotation = \&min_rotation_perl;

#*min_rotation = \&min_rotation_divsufsort;

1;
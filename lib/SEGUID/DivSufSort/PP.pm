package SEGUID::DivSufSort::PP;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT_OK = qw(min_rotation_divsufsort);

=head1 NAME

SEGUID::DivSufSort::PP - Pure Perl implementation of suffix array construction

=head1 SYNOPSIS

    use SEGUID::DivSufSort::PP qw(min_rotation_divsufsort);
    my $rotation = min_rotation_divsufsort("ATGCATGC");

=cut

sub divsufsort {
    my ($str) = @_;
    my $n = length($str);
    my @chars = split //, $str;
    
    # Initialize suffix array
    my @SA = (0) x $n;
    
    # Build suffix array using basic induced sorting
    _induce_sort(\@chars, \@SA);
    
    return \@SA;
}

sub _induce_sort {
    my ($chars, $SA) = @_;
    my $n = scalar(@$chars);
    
    # Type array
    my @type = _get_types($chars);
    
    # Get LMS positions
    my @lms_pos = _get_lms_positions(\@type);
    
    # Sort LMS substrings
    _sort_lms($chars, $SA, \@type, \@lms_pos);
    
    # Induce L-type suffixes
    _induce_l($chars, $SA, \@type);
    
    # Induce S-type suffixes
    _induce_s($chars, $SA, \@type);
}

sub _get_types {
    my ($chars) = @_;
    my $n = scalar(@$chars);
    my @type = ('S') x $n;
    
    for (my $i = $n - 2; $i >= 0; $i--) {
        if ($chars->[$i] gt $chars->[$i + 1]) {
            $type[$i] = 'L';
        }
        elsif ($chars->[$i] eq $chars->[$i + 1] && $type[$i + 1] eq 'L') {
            $type[$i] = 'L';
        }
    }
    
    return @type;
}

sub _get_lms_positions {
    my ($type) = @_;
    my @pos;
    for (my $i = 1; $i < scalar(@$type); $i++) {
        if ($type->[$i] eq 'S' && $type->[$i - 1] eq 'L') {
            push @pos, $i;
        }
    }
    return @pos;
}

sub _sort_lms {
    my ($chars, $SA, $type, $lms_pos) = @_;
    # Basic bucket sort for LMS substrings
    my %buckets;
    for my $pos (@$lms_pos) {
        push @{$buckets{$chars->[$pos]}}, $pos;
    }
    
    my $sa_idx = 0;
    for my $char (sort keys %buckets) {
        for my $pos (@{$buckets{$char}}) {
            $SA->[$sa_idx++] = $pos;
        }
    }
}

sub _induce_l {
    my ($chars, $SA, $type) = @_;
    # Induce sort L-type suffixes
    my $n = scalar(@$chars);
    my @bucket_heads;
    my $head = 0;
    
    for my $i (0..$n-1) {
        if ($SA->[$i] > 0 && $type->[$SA->[$i] - 1] eq 'L') {
            my $pos = $SA->[$i] - 1;
            my $char = $chars->[$pos];
            $bucket_heads[$head++] = $pos;
        }
    }
}

sub _induce_s {
    my ($chars, $SA, $type) = @_;
    # Induce sort S-type suffixes
    my $n = scalar(@$chars);
    my @bucket_tails;
    my $tail = $n - 1;
    
    for (my $i = $n - 1; $i >= 0; $i--) {
        if ($SA->[$i] > 0 && $type->[$SA->[$i] - 1] eq 'S') {
            my $pos = $SA->[$i] - 1;
            my $char = $chars->[$pos];
            $bucket_tails[$tail--] = $pos;
        }
    }
}

sub min_rotation_divsufsort {
    my ($str) = @_;
    my $n = length($str);
    return 0 if $n <= 1;
    
    # Double the string for circular comparison
    my $doubled = $str . $str;
    my $sa = divsufsort($doubled);
    
    # Find the first suffix that starts in the first half
    for my $pos (@$sa) {
        if ($pos < $n) {
            return $pos;
        }
    }
    
    return 0;  # Should never reach here
}

1;

=head1 DESCRIPTION

This module provides a pure Perl implementation of the suffix array construction algorithm,
specifically for finding the minimum rotation of a string. It's used as an alternative to
the C-based libdivsufsort when performance is not critical or when compilation is not possible.

=head1 AUTHOR

Gyorgy Babnigg <gbabnigg@gmail.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
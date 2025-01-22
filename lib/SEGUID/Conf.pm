package SEGUID::Conf;
use strict;
use warnings;
use Carp qw(croak);
use SEGUID::Manip qw(min_rotation_perl);
use base 'Exporter';

our @EXPORT_OK = qw(min_rotation set_min_rotation);
our $VERSION = '1.01';

=head1 NAME

SEGUID::Conf - Configuration module for SEGUID implementation

=head1 SYNOPSIS

    use SEGUID::Conf qw(min_rotation set_min_rotation);
    
    # Use built-in rotation
    set_min_rotation('built-in');
    my $rotated = min_rotation($sequence);

=head1 DESCRIPTION

This module provides configuration options for the SEGUID implementation,
particularly for controlling which minimum rotation algorithm is used.

=cut

# Store the current rotation function
my $current_rotation_func = \&min_rotation_perl;

=head2 min_rotation

    my $rotated = min_rotation($sequence);

Performs minimum rotation using the currently selected algorithm.

=cut

sub min_rotation {
    my ($s) = @_;
    return $current_rotation_func->($s);
}

=head2 set_min_rotation

    set_min_rotation($which);

Sets which minimum rotation implementation to use.
Currently supports: 'built-in'

Parameters:
    $which - String specifying which implementation to use ('built-in')

Throws:
    Error if an invalid implementation is specified

=cut

sub set_min_rotation {
    my ($which) = @_;
    
    # Input validation
    croak "Argument 'which' must be a string" 
        unless defined $which && !ref($which);
    
    if ($which eq 'built-in') {
        $current_rotation_func = \&min_rotation_perl;
    }
    # Note: pydivsufsort implementation is not available in Perl
    # We could potentially add other implementations here in the future
    else {
        croak "Argument 'which' should be 'built-in': $which";
    }
}

# Initialize with built-in implementation
set_min_rotation('built-in');

1;

=head1 NOTES

The Python implementation includes support for pydivsufsort, which is not
available in this Perl implementation. Only the built-in implementation
is currently supported.

=head1 AUTHOR

Gyorgy Babnigg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


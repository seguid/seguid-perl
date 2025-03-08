package SEGUID::Reprutils;
use strict;
use warnings;
use Carp qw(croak);
use SEGUID::Manip qw(reverse);
use base 'Exporter';

our @EXPORT_OK = qw(is_staggered escape_sequence_spec parse_sequence_string);
our $VERSION = '1.02';

=head1 NAME

SEGUID::Reprutils - Utilities for handling DNA/RNA sequence representations

=head1 SYNOPSIS

    use SEGUID::Reprutils qw(parse_sequence_string);
    my ($type, $spec, $watson, $crick) = parse_sequence_string("ACGT;TGCA");

=head1 DESCRIPTION

This module provides utilities for parsing and validating DNA/RNA sequence 
representations, particularly for double-stranded sequences.

=head1 FUNCTIONS

=cut

=head2 is_staggered

    my $staggered = is_staggered($watson, $crick);

Checks if either strand contains gaps (indicated by '-').

=cut

sub is_staggered {
    my ($watson, $crick) = @_;
    return ($watson =~ /-/ || $crick =~ /-/);
}

=head2 escape_sequence_spec

    my $escaped = escape_sequence_spec($spec);

Escapes newlines in sequence specifications for error messages.

=cut

sub escape_sequence_spec {
    my ($spec) = @_;
    $spec =~ s/\n/\\n/g;
    return $spec;
}

=head2 parse_sequence_string

    my ($type, $spec, $watson, $crick) = parse_sequence_string($spec);

Parses various sequence string formats. Returns sequence type and strands.

=cut

sub parse_sequence_string {
    my ($spec) = @_;
    
    croak "Argument must be a string" unless defined $spec;
    
    # Single-stranded sequence
    if ($spec =~ /^([0-9A-Za-z-]+)$/) {
        return ("ss", $spec);
    }
    
    # Watson-Crick pair separated by semicolon
    if ($spec =~ /^([0-9A-Za-z-]+);([0-9A-Za-z-]+)$/) {
        my ($watson, $crick) = ($1, $2);
        my $rcrick = reverse($crick);
        
        # Length validation
        if (length($watson) != length($crick)) {
            croak sprintf(
                "Double-strand sequence string specifies two strands of different lengths (%d != %d): '%s'",
                length($watson), length($crick), $spec
            );
        }
        
        # Stagger validation
        if (is_staggered($watson, $crick)) {
            if ($watson =~ /^-/ && $rcrick =~ /^-/) {
                croak sprintf(
                    "Please trim the staggering. Watson and Crick are both staggered at the beginning of the double-stranded sequence: '%s'",
                    $spec
                );
            }
            if ($watson =~ /-$/ && $rcrick =~ /-$/) {
                croak sprintf(
                    "Please trim the staggering. Watson and Crick are both staggered at the end of the double-stranded sequence: '%s'",
                    $spec
                );
            }
        }
        
        return ("ds", $spec, $watson, $crick);
    }
    
    # Watson-Crick pair separated by newline
    if ($spec =~ /^([0-9A-Za-z-]+)\n([0-9A-Za-z-]+)$/) {
        my ($watson, $rcrick) = ($1, $2);
        my $crick = reverse($rcrick);
        
        # Length validation
        if (length($watson) != length($crick)) {
            croak sprintf(
                "Double-strand sequence string specifies two strands of different lengths (%d != %d): '%s'",
                length($watson), length($crick), escape_sequence_spec($spec)
            );
        }
        
        # Stagger validation
        if (is_staggered($watson, $crick)) {
            if ($watson =~ /^-/ && $rcrick =~ /^-/) {
                croak sprintf(
                    "Please trim the staggering. Watson and Crick are both staggered at the beginning of the double-stranded sequence: '%s'",
                    escape_sequence_spec($spec)
                );
            }
            if ($watson =~ /-$/ && $rcrick =~ /-$/) {
                croak sprintf(
                    "Please trim the staggering. Watson and Crick are both staggered at the end of the double-stranded sequence: '%s'",
                    escape_sequence_spec($spec)
                );
            }
        }
        
        return ("ds", $spec, $watson, $crick);
    }
    
    # If we get here, the format is invalid
    croak sprintf("Syntax error in sequence string: '%s'", escape_sequence_spec($spec));
}

1;

=head1 AUTHOR

Your Name

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
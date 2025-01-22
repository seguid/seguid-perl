package SEGUID::Alphabet;

use strict;
use warnings;
use Carp qw(croak);

use base 'Exporter';
our @EXPORT_OK = qw(tablefactory);

# Define alphabets as a hash reference
our $alphabets = {
    '{DNA}'             => 'GC,AT',
    '{RNA}'             => 'GC,AU',
    '{DNA-extended}'    => 'GC,AT,BV,DH,KM,SS,RY,WW,NN',
    '{RNA-extended}'    => 'GC,AU,BV,DH,KM,SS,RY,WW,NN',
    '{protein}'         => 'A,C,D,E,F,G,H,I,K,L,M,N,P,Q,R,S,T,V,W,Y,O,U',
    '{protein-extended}'=> 'A,C,D,E,F,G,H,I,K,L,M,N,P,Q,R,S,T,V,W,Y,O,U,B,J,X,Z',
    '{proteinV1}'       => 'A,C,D,E,F,G,H,I,K,L,M,N,P,Q,R,S,T,V,W,Y',

};

sub tablefactory {
    my ($argument) = @_;
    
    # Replace predefined alphabet names with their values
    foreach my $name (keys %$alphabets) {
        $argument =~ s/\Q$name\E/$alphabets->{$name}/g;
    }
    
    my $n_expected = -1;
    my %alphabet;
    
    # Process each specification in the argument
    foreach my $spec (split /,/, $argument) {
        my $n = length($spec);
        
        if ($n_expected < 0) {
            $n_expected = $n;
        }
        else {
            croak "Inconsistent specification length for '$spec'" 
                unless $n == $n_expected;
        }
        
        if ($n == 1) {
            $alphabet{$spec} = "";
        }
        elsif ($n == 2) {
            my ($first, $second) = split //, $spec;
            
            # Handle first character
            if (exists $alphabet{$first}) {
                $alphabet{$first} .= $second;
            }
            else {
                $alphabet{$first} = $second;
            }
            
            # Handle second character
            if (exists $alphabet{$second}) {
                $alphabet{$second} .= $first;
            }
            else {
                $alphabet{$second} = $first;
            }
        }
        else {
            croak "Unknown alphabet specification: $spec";
        }
    }
    
    return \%alphabet;
}

1;

=head1 DESCRIPTION

This module defines the alphabets used.

=head1 AUTHOR

Gyorgy Babnigg <gbabnigg@gmail.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

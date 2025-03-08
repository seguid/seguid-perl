package SEGUID::Cli;
use strict;
use warnings;
use Carp qw(croak);
use Getopt::Long qw(GetOptionsFromArray);
use Pod::Usage qw(pod2usage);
use SEGUID::Chksum qw(seguid lsseguid csseguid ldseguid cdseguid);
use SEGUID::Reprutils qw(parse_sequence_string);
use SEGUID::Manip qw(reverse);

our $VERSION = '1.02';

=head1 NAME

SEGUID::Cli - Command-line interface for SEGUID operations

=head1 SYNOPSIS

    use SEGUID::Cli;
    SEGUID::Cli::run(@ARGV);

=head1 DESCRIPTION

This module provides command-line interface functionality for SEGUID operations.

=cut

my $USAGE = <<'END_USAGE';
Usage: seguid [options] < sequence.txt

Options:
    --help          Display this help message
    --version       Display version information
    --type=TYPE     Type of checksum to calculate:
                    seguid (default), lsseguid, csseguid, ldseguid, cdseguid
    --alphabet=STR  Set of symbols for input sequence:
                    {DNA} (default), {RNA}, {protein}, etc.
    --form=FORM     Form of checksum to display:
                    long (default), short, both

Predefined alphabets:
 '{DNA}'              Complementary DNA symbols (= 'AT,CG')
 '{DNA-extended}'     Extended DNA (= '{DNA},BV,DH,KM,SS,RY,WW,NN')
 '{RNA}'              Complementary RNA symbols (= 'AU,CG')
 '{RNA-extended}'     Extended RNA (= '{RNA},BV,DH,KM,SS,RY,WW,NN')
 '{protein}'          Amino-acid symbols (= 'A,C,D,E,F,G,H,I,K,L,M,N,P,Q,R,S,T,V,W,Y')
 '{protein-extended}' Amino-acid symbols (= '{protein},O,U,B,J,Z,X')

Examples:
 echo 'ACGT' | seguid --type=lsseguid
 echo 'ACGT;TGCA' | seguid --type=ldseguid
 echo '-CGT;ACGT' | seguid --type=ldseguid
 echo 'ACGU' | seguid --type=lsseguid --alphabet='{RNA}'

Version: $VERSION
Copyright: Gyorgy Babnigg (2024)
License: Same terms as Perl itself
END_USAGE

sub run {
    my (@args) = @_;
    
    # Default values
    my %opts = (
        help     => 0,
        version  => 0,
        type     => 'seguid',
        alphabet => '{DNA}',
        form     => 'long',
    );
    
    # Parse command line options
    GetOptionsFromArray(
        \@args,
        'help'       => \$opts{help},
        'version'    => \$opts{version},
        'type=s'     => \$opts{type},
        'alphabet=s' => \$opts{alphabet},
        'form=s'     => \$opts{form},
    ) or pod2usage(-message => $USAGE, -exitval => 1);
    
    # Handle help and version
    if ($opts{help}) {
        print $USAGE;
        return 0;
    }
    
    if ($opts{version}) {
        print "$VERSION\n";
        return 0;
    }
    
    # Read sequence from STDIN
    my @lines;
    while (my $line = <STDIN>) {
        chomp $line;
        push @lines, $line;
    }
    my $seq = join("\n", @lines);
    
    # Process sequence based on type
    my $result;
    eval {
        if ($opts{type} eq 'seguid') {
            $result = seguid($seq, $opts{alphabet}, $opts{form});
        }
        elsif ($opts{type} eq 'lsseguid') {
            $result = lsseguid($seq, $opts{alphabet}, $opts{form});
        }
        elsif ($opts{type} eq 'csseguid') {
            $result = csseguid($seq, $opts{alphabet}, $opts{form});
        }
        elsif ($opts{type} =~ /^[lc]dseguid$/) {
            my ($void1, $void2, $watson, $crick) = parse_sequence_string($seq);
            if ($opts{type} eq 'ldseguid') {
                $result = ldseguid($watson, $crick, $opts{alphabet}, $opts{form});
            }
            else {
                $result = cdseguid($watson, $crick, $opts{alphabet}, $opts{form});
            }
        }
        else {
            die "Unknown --type='$opts{type}'\n";
        }
    };
    
    if ($@) {
        chomp $@;
        print STDERR "Error: $@\n";
        return 1;
    }
    
    # Handle tuple results from 'both' form
    if (ref($result) eq 'ARRAY') {
        $result = join(' ', @$result);
    }
    
    print "$result\n";
    return 0;
}

1;

=head1 AUTHOR

Gyorgy Babnigg <gbabnigg@gmaill.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.



use strict;
use warnings;
use SEGUID::Cli;

exit SEGUID::Cli::run(@ARGV);

=cut

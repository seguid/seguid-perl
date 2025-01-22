#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use SEGUID::Chksum qw(seguid lsseguid csseguid ldseguid cdseguid seguidv1 seguidv1urlsafe);
use SEGUID::Manip qw(rotate_to_min min_rotation_perl min_rotation rotate);

use SEGUID::DivSufSort::PP qw(min_rotation_divsufsort);




# Example 1: Basic DNA sequence
print "Example 1: Basic DNA sequence\n";
my $dna = "ACGT";
print "Sequence: $dna\n";
print "SEGUID: ", seguid($dna), "\n\n";

# Example 2: RNA sequence
print "Example 2: RNA sequence\n";
my $rna = "ACGU";
print "Sequence: $rna\n";
print "LSSEGUID: ", lsseguid($rna, "{RNA}"), "\n\n";

# Example 3: Circular DNA sequence
print "Example 3: Circular DNA sequence\n";
my $circular = "ATTT";
print "Sequence: $circular\n";
print "CSSEGUID: ", csseguid($circular), "\n";
print "Note: Rotated sequence 'TTTA' gives same checksum:\n";
print "CSSEGUID: ", csseguid("TTTA"), "\n\n";

# Example 4: Double-stranded DNA with staggered ends
print "Example 4: Double-stranded DNA with staggered ends\n";
my $watson = "--ATACGACTCACTATAGGGGAATTGTGAGCGGATAACAATTCC";
my $crick =  "-GAATTGTTATCCGCTCACAATTCCCCTATAGTGAGTCGTATTA";
print "Watson: $watson\n";
print "Crick:  $crick\n";
print "LDSEGUID: ", ldseguid($watson, $crick), "\n\n";

# Example 5: Protein sequence
print "Example 5: Protein sequence\n";
my $protein = "MKWVTFISLLLLFSSAYS";
print "Sequence: $protein\n";
print "LSSEGUID: ", lsseguid($protein, "{protein}"), "\n\n";

# Example 6: Different output forms
print "Example 6: Different output forms\n";
print "Long form:  ", lsseguid($dna, "{DNA}", "long"), "\n";
print "Short form: ", lsseguid($dna, "{DNA}", "short"), "\n";
my $both = lsseguid($dna, "{DNA}", "both");
print "Both forms: ", $both, "\n\n";

# Example 7: Custom alphabet
print "Example 7: Custom alphabet\n";
my $custom_seq = "XY";
print "Sequence with custom alphabet 'XY,ZW': $custom_seq\n";
print "LSSEGUID: ", lsseguid($custom_seq, "XY,ZW"), "\n\n";

# Example 8: Extended alphabet
print "Example 8: Extended DNA alphabet\n";
my $extended = "ACGTRYSWKMBDHVN";
print "Sequence: $extended\n";
print "LSSEGUID: ", lsseguid($extended, "{DNA-extended}"), "\n\n";

# Example 9: Linear single-stranded DNA
print "Example 9: Linear single-stranded DNA\n";
my $linearLS = "TATGCCAA";
print "Sequence: $linearLS\n";
print "LSSEGUID: ", lsseguid($linearLS, "{DNA-extended}"), "; lsseguid=EevrucUNYjqlsxrTEK8JJxPYllk\n\n";

# Example 10: Linear single-stranded DNA
print "Example 10: Linear single-stranded DNA\n";
my $linearLS2 = "AATATGCC";
print "Sequence: $linearLS2\n";
print "LSSEGUID: ", lsseguid($linearLS2, "{DNA-extended}"), "; lsseguid=XsJzXMxgv7sbpqIzFH9dgrHUpWw\n\n";

# Example 11: Circular single-stranded DNA
print "Example 11: Circular single-stranded DNA\n";
my $circ = "TATGCCAA";
print "Sequence: $circ\n";
print "CSSEGUID: ", csseguid($circ, "{DNA-extended}"), "; csseguid=XsJzXMxgv7sbpqIzFH9dgrHUpWw\n\n";


# Example 12: Circular single-stranded DNA
print "Example 12: Circular single-stranded DNA\n";
my $circ2 = "GCCAATAT";
print "Sequence: $circ2\n";
print "CSSEGUID: ", csseguid($circ2, "{DNA-extended}"), "; csseguid=XsJzXMxgv7sbpqIzFH9dgrHUpWw\n\n";


print "Double-stranded DNA examples\n";

print "LDSEGUID: ", ldseguid("AATATGCC", "GGCATATT"), "; ldseguid=dUxN7YQyVInv3oDcvz8ByupL44A\n\n";

print "LDSEGUID: ", ldseguid("GGCATATT", "AATATGCC"), "; ldseguid=dUxN7YQyVInv3oDcvz8ByupL44A\n\n";

# test rotation

print "Rotation test of 'GGCATATT'\n", rotate_to_min("GGCATATT"), "\n\n";

print "Min rotation of 'ACAACAAACAACACAAACAAACACAA' (min_rotation_perl)\n", min_rotation_perl("ACAACAAACAACACAAACAAACACAAC"), "\n\n";

print "Rotation test of 'ACAACAAACAACACAAACAAACACAAC' (min_rotation)\n", min_rotation("ACAACAAACAACACAAACAAACACAAC"), "\n\n";





#print "CDSEGUID: ", cdseguid("TATGCCAA", "TTGGCATA"), "; cdseguid=dUxN7YQyVInv3oDcvz8ByupL44A\n\n";

#print "CDSEGUID: ", cdseguid("TATGCCAA", "ATACGGTT"), "; cdseguid=\n\n";

#exit(0);

print "CDSEGUID (TTGGCATA, TATGCCAA): ", cdseguid("TTGGCATA", "TATGCCAA"), "; cdseguid=dUxN7YQyVInv3oDcvz8ByupL44A\n\n";

print "CDSEGUID: (AATATGCC, GGCATATT) ", cdseguid("AATATGCC", "GGCATATT"), "; cdseguid=dUxN7YQyVInv3oDcvz8ByupL44A\n\n";


print "\n\nSEGUID V1 Examples\n\n";


print "seguidv1: ACDEFGHIKLMNPQRSTVWY ", seguidv1("ACDEFGHIKLMNPQRSTVWY"), "; seguidv1=tRntFmqHM23Z+bMbNDfKXFC1+Es\n\n";

print "seguidv1urlsafe: ACDEFGHIKLMNPQRSTVWY ", seguidv1urlsafe("ACDEFGHIKLMNPQRSTVWY"), "; seguidv1urlsafe=tRntFmqHM23Z-bMbNDfKXFC1-Es\n\n";

print "seguidv1: MGDRSEGPGPTRPGPPGIGP ", seguidv1("MGDRSEGPGPTRPGPPGIGP"), "; seguidv1=N/DxuiQwt3rU+nDzU5/q+CaRuQM\n\n";

print "seguidv1urlsafe: MGDRSEGPGPTRPGPPGIGP ", seguidv1urlsafe("MGDRSEGPGPTRPGPPGIGP"), "; seguidv1urlsafe=N_DxuiQwt3rU-DzU5_q-CaRuQM\n\n";

print "seguidv1urlsafe: mgDRSEGpgpTRPGPPGigp ", seguidv1urlsafe("mgDRSEGpgpTRPGPPGigp"), "; seguidv1urlsafe=N_DxuiQwt3rU-DzU5_q-CaRuQM\n\n";



print "seguidv1urlsafe: MGDRSEGPGPTRPGPPGIGPB ", seguidv1urlsafe("MGDRSEGPGPTRPGPPGIGPB"), "; seguidv1urlsafe=N_DxuiQwt3rU-DzU5_q-CaRuQM\n\n";

print "seguidv1urlsafe: MGDRSEGPGPTRPGPPGIGPO ", seguidv1urlsafe("MGDRSEGPGPTRPGPPGIGPO"), "; seguidv1urlsafe=N_DxuiQwt3rU-DzU5_q-CaRuQM\n\n";

print "seguidv1urlsafe: 12_*!@#\$\%^&MGDRSEGPGPTRPGPPGIGPO ", seguidv1urlsafe("12_*!@#\$\%^&MGDRSEGPGPTRPGPPGIGPO"), "; seguidv1urlsafe=N_DxuiQwt3rU-DzU5_q-CaRuQM\n\n";

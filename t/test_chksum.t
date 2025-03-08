#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 44;
use Test::Exception;

BEGIN {
    use_ok('SEGUID::Chksum', qw(
        seguid 
        lsseguid 
        csseguid 
        ldseguid 
        cdseguid
        seguidv1
        seguidv1urlsafe
        ccseguid
    ));
}

# Test helper function to verify checksum format
sub is_valid_checksum {
    my ($checksum, $prefix, $is_long) = @_;
    
    if ($is_long) {
        # Long form should be prefix + 27 base64 chars
        return 0 unless $checksum =~ /^$prefix[A-Za-z0-9+\/_-]{27}$/;
    } else {
        # Short form should be exactly 6 chars
        return 0 unless $checksum =~ /^[A-Za-z0-9+\/_-]{6}$/;
    }
    return 1;
}

# Test basic sequences with seguid (v1)
{
    # Basic DNA sequence
    my $seq = "ACGT";
    my $seqRNA = "ACGU";
    my $checksum = seguid($seq);
    ok(is_valid_checksum($checksum, 'seguid=', 1), 'Valid v1 seguid format');
    
    # Test form parameter
    my $short = seguid($seq, '{DNA}', 'short');
    ok(is_valid_checksum($short, '', 0), 'Valid short seguid format');
    
    my $both = seguid($seq, '{DNA}', 'both');

    is(seguid("AT"), "seguid=Ax/RG6hzSrMEEWoCO1IWMGska+4", 'Correct seguid'); #
    
    # Testing  seguidv1
    my $seqV1 = "ACDEFGHIKLMNPQRSTVXY";

    lives_ok { seguidv1($seqV1, '{proteinV1}') } 'Protein alphabet (V1) accepted';
    throws_ok { seguidv1("BOUZ", '{proteinV1}') } qr/A protein sequence must not be empty/, 'invalid protein sequence caught okay';

    
    my $longV1 = seguidv1($seqV1, '{proteinV1}', 'long');

    is(seguidv1("ACDEFGHIKLMNPQRSTVWY"),               "seguidv1=tRntFmqHM23Z+bMbNDfKXFC1+Es", 'Correct seguidv1');
    is(seguidv1urlsafe("ACDEFGHIKLMNPQRSTVWY"), "seguidv1urlsafe=tRntFmqHM23Z-bMbNDfKXFC1-Es", 'Correct seguidv1urlsafe'); # / -> _; + -> -

    is(seguidv1("MGDRSEGPGPTRPGPPGIGP"), "seguidv1=N/DxuiQwt3rU+nDzU5/q+CaRuQM", 'Correct seguidv1');
    is(seguidv1urlsafe("MGDRSEGPGPTRPGPPGIGP"), "seguidv1urlsafe=N_DxuiQwt3rU-nDzU5_q-CaRuQM", 'Correct seguidv1urlsafe'); # / -> _; + -> -
    is(seguidv1urlsafe("mgDRSEGpgpTRPGPPGigp"), "seguidv1urlsafe=N_DxuiQwt3rU-nDzU5_q-CaRuQM", 'Correct seguidv1urlsafe'); # / -> _; + -> -
    is(seguidv1urlsafe("MGDRSEGPGPTRPGPPGIGPB"), "seguidv1urlsafe=N_DxuiQwt3rU-nDzU5_q-CaRuQM", 'Correct seguidv1urlsafe'); # / -> _; + -> -
    is(seguidv1urlsafe("MGDRSEGPGPTRPGPPGIGPO"), "seguidv1urlsafe=N_DxuiQwt3rU-nDzU5_q-CaRuQM", 'Correct seguidv1urlsafe'); # / -> _; + -> -
    is(seguidv1urlsafe("12_*!@#\$\%^&MGDRSEGP GPTRPGPP  -GIGPO"), "seguidv1urlsafe=N_DxuiQwt3rU-nDzU5_q-CaRuQM", 'Correct seguidv1urlsafe'); # / -> _; + -> -




}

# Test linear single-stranded sequences (lsseguid)
{
    my $seq = "ACGT";
    my $seqRNA = "ACGUBVDHKMSRYWN";

    my $checksum = lsseguid($seq);
    ok(is_valid_checksum($checksum, 'lsseguid=', 1), 'Valid lsseguid format');
    
    # Test different forms
    my $short = lsseguid($seq, '{DNA}', 'short');
    ok(is_valid_checksum($short, '', 0), 'Valid short lsseguid format');
    

    
    # Test alphabets
    lives_ok { lsseguid($seq, '{DNA-extended}') } 'Extended DNA alphabet accepted';
    lives_ok { lsseguid($seqRNA, '{RNA-extended}') } 'Extended RNA alphabet accepted';
}



# Test circular single-stranded sequences (csseguid)
{
    my $seq = "ACGT";
    my $checksum = csseguid($seq);
    ok(is_valid_checksum($checksum, 'csseguid=', 1), 'Valid csseguid format');
    
    # Test rotations return same checksum
    my $rotated = csseguid("GTAC");
    is($rotated, $checksum, 'Rotated sequence produces same checksum');
    
    # Test different forms
    my $short = csseguid($seq, '{DNA}', 'short');
    ok(is_valid_checksum($short, '', 0), 'Valid short csseguid format');


}




# Test linear double-stranded sequences (ldseguid)
{
    my $watson = "-TATGCC";
    my $crick = "-GCATAC";


    
    my $checksum = ldseguid($watson, $crick);
    ok(is_valid_checksum($checksum, 'ldseguid=', 1), 'Valid ldseguid format');
    
    # Test different forms
    my $short = ldseguid($watson, $crick, '{DNA}', 'short');
    ok(is_valid_checksum($short, '', 0), 'Valid short ldseguid format');
    
    # Test error conditions
    throws_ok { ldseguid($watson, substr($crick, 0, -1)) }
        qr/must be equal length/, 'Detects unequal length strands';
        

}


# Test circular double-stranded sequences (cdseguid)
{
    my $watson = "GTATGCC";
    my $crick = "GGCATAC";


    my $checksum = cdseguid($watson, $crick);
    ok(is_valid_checksum($checksum, 'cdseguid=', 1), 'Valid cdseguid format');
    
    # Test rotations return same checksum
    my $rotated = cdseguid($watson, $crick);
    is($rotated, $checksum, 'Rotated sequence produces same checksum');
    
    # Test different forms
    my $short = cdseguid($watson, $crick, '{DNA}', 'short');
    ok(is_valid_checksum($short, '', 0), 'Valid short cdseguid format');


    $watson = "TTGGCATA";
    $crick = "TATGCCAA";

    $checksum = cdseguid($watson, $crick);
    ok(is_valid_checksum($checksum, 'cdseguid=', 1), 'Valid cdseguid format');

    $watson = "AATATGCC";
    $crick = "GGCATATT";

    $checksum = cdseguid($watson, $crick);
    ok(is_valid_checksum($checksum, 'cdseguid=', 1), 'Valid cdseguid format');


}


# Test circular DNA sequence - only one strand is provided (ccseguid)
{


    my $watson = "tcgcgcgtttcggtgatgacggtgaaaacctctgacacatgcagctcccggagacggtcacagcttgtctgtaagcggatgccgggagcagacaagcccgtcagggcgcgtcagcgggtgttggcgggtgtcggggctggcttaactatgcggcatcagagcagattgtactgagagtgcaccatatgcggtgtgaaataccgcacagatgcgtaaggagaaaataccgcatcaggcgccattcgccattcaggctgcgcaactgttgggaagggcgatcggtgcgggcctcttcgctattacgccagctagaggaccagccgcgtaacctggcaaaatcggttacggttgagtaataaatggatgccctgcgtaagcgggtgtgggcggacaataaagtcttaaactgaacaaaatagatctaaactatgacaataaagtcttaaactagacagaatagttgtaaactgaaatcagtccagttatgctgtgaaaaagcatactggacttttgttatggctaaagcaaactcttcattttctgaagtgcaaattgcccgtcgtattaaagaggggcgtggggtcgacgatatcatgcatgagctcactagtggatcccccgggctgcaggaattcctcgagaagcttgggcccggtacctcgcgaaggccttgcaggccaaccagataagtgaaatctagttccaaactattttgtcatttttaattttcgtattagcttacgacgctacacccagttcccatctattttgtcactcttccctaaataatccttaaaaactccatttccacccctcccagttcccaactattttgtccgcccacagcggggcatttttcttcctgttatgtttgggcgctgcattaatgaatcggccaacgcgcggggagaggcggtttgcgtattgggcgctcttccgcttcctcgctcactgactcgctgcgctcggtcgttcggctgcggcgagcggtatcagctcactcaaaggcggtaatacggttatccacagaatcaggggataacgcaggaaagaacatgtgagcaaaaggccagcaaaaggccaggaaccgtaaaaaggccgcgttgctggcgtttttccataggctccgcccccctgacgagcatcacaaaaatcgacgctcaagtcagaggtggcgaaacccgacaggactataaagataccaggcgtttccccctggaagctccctcgtgcgctctcctgttccgaccctgccgcttaccggatacctgtccgcctttctcccttcgggaagcgtggcgctttctcatagctcacgctgtaggtatctcagttcggtgtaggtcgttcgctccaagctgggctgtgtgcacgaaccccccgttcagcccgaccgctgcgccttatccggtaactatcgtcttgagtccaacccggtaagacacgacttatcgccactggcagcagccactggtaacaggattagcagagcgaggtatgtaggcggtgctacagagttcttgaagtggtggcctaactacggctacactagaaggacagtatttggtatctgcgctctgctgaagccagttaccttcggaaaaagagttggtagctcttgatccggcaaacaaaccaccgctggtagcggtggtttttttgtttgcaagcagcagattacgcgcagaaaaaaaggatctcaagaagatcctttgatcttttctacggggtctgacgctcagtggaacgaaaactcacgttaagggattttggtcatgagattatcaaaaaggatcttcacctagatccttttaaattaaaaatgaagttttaaatcaatctaaagtatatatgagtaaacttggtctgacagttaccaatgcttaatcagtgaggcacctatctcagcgatctgtctatttcgttcatccatagttgcctgactccccgtcgtgtagataactacgatacgggagggcttaccatctggccccagtgctgcaatgataccgcgagacccacgctcaccggctccagatttatcagcaataaaccagccagccggaagggccgagcgcagaagtggtcctgcaactttatccgcctccatccagtctattaattgttgccgggaagctagagtaagtagttcgccagttaatagtttgcgcaacgttgttgccattgctacaggcatcgtggtgtcacgctcgtcgtttggtatggcttcattcagctccggttcccaacgatcaaggcgagttacatgatcccccatgttgtgcaaaaaagcggttagctccttcggtcctccgatcgttgtcagaagtaagttggccgcagtgttatcactcatggttatggcagcactgcataattctcttactgtcatgccatccgtaagatgcttttctgtgactggtgagtactcaaccaagtcattctgagaatagtgtatgcggcgaccgagttgctcttgcccggcgtcaatacgggataataccgcgccacatagcagaactttaaaagtgctcatcattggaaaacgttcttcggggcgaaaactctcaaggatcttaccgctgttgagatccagttcgatgtaacccactcgtgcacccaactgatcttcagcatcttttactttcaccagcgtttctgggtgagcaaaaacaggaaggcaaaatgccgcaaaaaagggaataagggcgacacggaaatgttgaatactcatactcttcctttttcaatattattgaagcatttatcagggttattgtctcatgagcggatacatatttgaatgtatttagaaaaataaacaaataggggttccgcgcacatttccccgaaaagtgccacctgacgtctaagaaaccattattatcatgacattaacctataaaaataggcgtatcacgaggccctttcgtc";

    my $checksum = ccseguid($watson);
    ok(is_valid_checksum($checksum, 'ccseguid=', 1), 'Valid ccseguid format');
    



}



# Test error conditions across all functions
{
    # Empty sequences
    throws_ok { seguid("") } qr/must not be empty/, 'Detects empty sequence';
    throws_ok { lsseguid("") } qr/must not be empty/, 'Detects empty sequence';
    throws_ok { csseguid("") } qr/must not be empty/, 'Detects empty sequence';
    throws_ok { ldseguid("", "ACGT") } qr/must not be empty/, 'Detects empty Watson strand';
    throws_ok { cdseguid("ACGT", "") } qr/must not be empty/, 'Detects empty Crick strand';
    
    # Invalid alphabets
    throws_ok { seguid("ACGT", '{invalid}') } qr/Unknown alphabet/, 'Detects invalid alphabet';
    throws_ok { lsseguid("12345", '{DNA}') } qr/not in the 'alphabet'/, 'Detects invalid characters';
    
    # Invalid forms
    throws_ok { seguid("ACGT", '{DNA}', 'invalid') } qr/Invalid form/, 'Detects invalid form';
}



# Test special cases
{
    # Very long sequences
    my $long_seq = "A" x 1000;
    lives_ok { lsseguid($long_seq) } 'Handles long sequences';
    

}

# Test idempotency
{
    my $seq = "ACGT";
    my $checksum1 = lsseguid($seq);
    my $checksum2 = lsseguid($seq);
    is($checksum1, $checksum2, 'Checksum function is idempotent');
    
    my $watson = "ACGT";
    my $crick = "ACGT";
    $checksum1 = cdseguid($watson, $crick);
    $checksum2 = cdseguid($watson, $crick);
    is($checksum1, $checksum2, 'Double-stranded checksum is idempotent');
}

# Test Base64url encoding
{
    # Generate sequence likely to produce '+' or '/' in base64
    my $seq = "A" x 30;  # Long sequence of As
    
    my $v1 = seguid($seq);  # Uses standard base64
    my $v2 = lsseguid($seq);  # Uses base64url
    
    like($v1, qr/[+\/]/, 'v1 uses standard base64 encoding');
    unlike($v2, qr/[+\/]/, 'v2 uses URL-safe base64 encoding');
    like($v2, qr/[-_]/, 'v2 contains URL-safe characters');
}



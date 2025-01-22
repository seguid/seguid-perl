#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 23;
use Test::Exception;

BEGIN {
    use_ok('SEGUID::Reprutils', qw(
        is_staggered 
        escape_sequence_spec 
        parse_sequence_string
    ));
}

# Test is_staggered()
{
    ok(!is_staggered('ACGT', 'TGCA'), 'Non-staggered sequences return false');
    ok(is_staggered('ACGT-', 'TGCA-'), 'Sequences with gaps return true');
    ok(is_staggered('-CGT', 'TGCA'), 'Left-staggered sequence returns true');
    ok(is_staggered('ACGT', 'TGC-'), 'Right-staggered sequence returns true');
    ok(!is_staggered('', ''), 'Empty sequences are not staggered');
}

# Test escape_sequence_spec()
{
    is(escape_sequence_spec("ACGT"), "ACGT", 'String without newlines unchanged');
    is(escape_sequence_spec("ACGT\nTGCA"), "ACGT\\nTGCA", 'Newlines are escaped');
    is(escape_sequence_spec("AC\nGT\nTG"), "AC\\nGT\\nTG", 'Multiple newlines are escaped');
    is(escape_sequence_spec(""), "", 'Empty string returns empty string');
}

# Test parse_sequence_string()
{
    # Test single-stranded sequences
    {
        my ($type, $spec) = parse_sequence_string("ACGT");
        is($type, "ss", 'Single strand identified correctly');
        is($spec, "ACGT", 'Single strand sequence preserved');
    }

    # Test double-stranded sequences with semicolon separator
    {
        my ($type, $spec, $watson, $crick) = parse_sequence_string("ACGT;TGCA");
        is($type, "ds", 'Double strand identified correctly');
        is($spec, "ACGT;TGCA", 'Double strand specification preserved');
        is($watson, "ACGT", 'Watson strand extracted correctly');
        is($crick, "TGCA", 'Crick strand extracted correctly');
    }

    # Test double-stranded sequences with newline separator
    {
        my ($type, $spec, $watson, $crick) = parse_sequence_string("ACGT\nTGCA");
        is($type, "ds", 'Double strand with newline identified correctly');
        is($spec, "ACGT\nTGCA", 'Double strand with newline specification preserved');
        is($watson, "ACGT", 'Watson strand from newline format extracted correctly');
        is($crick, "ACGT", 'Crick strand from newline format extracted correctly'); # not TGCA since separated by newline and aligned as complementary strands
    }

    # Test error conditions
    throws_ok { parse_sequence_string("ACGT;TGC") }
        qr/different lengths/, 'Detects strands of different lengths';

    throws_ok { parse_sequence_string("-CGT;GCA-") }
        qr/staggered at the beginning/, 'Detects double staggering at start';

    throws_ok { parse_sequence_string("ACG-;-TGC") }
        qr/staggered at the end/, 'Detects double staggering at end';
}



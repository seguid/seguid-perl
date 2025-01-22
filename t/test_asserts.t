#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;
use Test::Exception;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use SEGUID::Asserts qw(assert_in_alphabet assert_alphabet assert_complementary);
use SEGUID::Alphabet qw(tablefactory);

# Test assert_in_alphabet
subtest 'assert_in_alphabet Tests' => sub {
    plan tests => 8;
    
    # Create test alphabet
    my $alphabet = { 'A' => 1, 'C' => 1, 'G' => 1, 'T' => 1, '-' => 1 };
    
    # Test valid cases
    lives_ok(
        sub { assert_in_alphabet('ACGT', $alphabet) },
        'Valid DNA sequence'
    );
    
    lives_ok(
        sub { assert_in_alphabet('', $alphabet) },
        'Empty sequence'
    );
    
    lives_ok(
        sub { assert_in_alphabet('A-GT', $alphabet) },
        'Sequence with gap'
    );
    
    # Test invalid cases
    throws_ok(
        sub { assert_in_alphabet('ACGTX', $alphabet) },
        qr/Detected symbols X/,
        'Invalid character detected'
    );
    
    throws_ok(
        sub { assert_in_alphabet('ACGT', {}) },
        qr/must not be empty/,
        'Empty alphabet'
    );
    
    throws_ok(
        sub { assert_in_alphabet(undef, $alphabet) },
        qr/must be a string/,
        'Undefined sequence'
    );
    
    throws_ok(
        sub { assert_in_alphabet('ACGT', undef) },
        qr/must be a hashref/,
        'Undefined alphabet'
    );
    
    # Test with special characters
    my $special_alphabet = { 'A' => 1, '-' => 1, "\n" => 1, ';' => 1 };
    lives_ok(
        sub { assert_in_alphabet("A-\n;", $special_alphabet) },
        'Special characters accepted'
    );
};

# Test assert_alphabet
subtest 'assert_alphabet Tests' => sub {
    plan tests => 4;
    
    # Test DNA complementarity table
    my $dna = { 'A' => 'T', 'T' => 'A', 'G' => 'C', 'C' => 'G' };
    lives_ok(
        sub { assert_alphabet($dna) },
        'Valid DNA alphabet'
    );
    
    # Test RNA complementarity table
    my $rna = { 'A' => 'U', 'U' => 'A', 'G' => 'C', 'C' => 'G' };
    lives_ok(
        sub { assert_alphabet($rna) },
        'Valid RNA alphabet'
    );
    
    # Test invalid cases
    throws_ok(
        sub { assert_alphabet({ 'A' => 'T', 'C' => 'X' }) },
        qr/Detected keys/,
        'Invalid complementarity'
    );
    
    throws_ok(
        sub { assert_alphabet(undef) },
        qr/must be a hashref/,
        'Undefined alphabet'
    );
};

# Test assert_complementary
subtest 'assert_complementary Tests' => sub {
    plan tests => 7;
    
    # Test valid DNA pairs with reversed Crick strand
    lives_ok(
        sub { assert_complementary('ACGT', reverse('ACGT'), '{DNA}') },
        'Valid DNA pair'
    );
    
    # Test with gaps - note Crick strand is reversed
    lives_ok(
        sub { assert_complementary('A-GT', reverse('A-CT'), '{DNA}') },
        'Valid pair with gaps'
    );
    
    # Test invalid cases
    throws_ok(
        sub { assert_complementary('ACGT', reverse('AGCT'), '{DNA}') },
        qr/Non-complementary basepair/,
        'Non-complementary pair'
    );
    
    throws_ok(
        sub { assert_complementary('ACG', 'TGCA', '{DNA}') },
        qr/must be equal length/,
        'Unequal lengths'
    );
    
    # Test with RNA - note Crick strand is reversed
    lives_ok(
        sub { assert_complementary('ACGU', reverse('ACGU'), '{RNA}') },
        'Valid RNA pair'
    );
    
    # Test invalid alphabet
    throws_ok(
        sub { assert_complementary('ACGT', 'TGCA', '{protein}') },
        qr/single-stranded alphabet/,
        'Invalid alphabet type'
    );
    
    # Test with custom alphabet
    lives_ok(
        sub { assert_complementary('ACGT', reverse('ACGT'), 'AT,CG') },
        'Custom complementarity alphabet'
    );
};
#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 13;
use Test::Exception;

BEGIN {
    use_ok('SEGUID::Conf', qw(min_rotation set_min_rotation));
}

# Test initial configuration
{
    # Should be set to built-in implementation by default
    my $result = min_rotation("TGCAACGT");
    ok(defined $result, 'Default rotation function returns a result');
    is(ref($result), '', 'Default rotation function returns a scalar');
    like($result, qr/^\d+$/, 'Default rotation function returns a number');
}

# Test setting configuration
{
    # Test valid configuration
    lives_ok { set_min_rotation('built-in') }
        'Can set rotation to built-in implementation';
    
    # Test invalid configurations
    throws_ok { set_min_rotation('invalid-impl') }
        qr/should be 'built-in'/, 
        'Detects invalid implementation name';
        
    throws_ok { set_min_rotation() }
        qr/must be a string/, 
        'Detects missing implementation argument';
        
    throws_ok { set_min_rotation(undef) }
        qr/must be a string/, 
        'Detects undefined implementation argument';
        
    throws_ok { set_min_rotation({}) }
        qr/must be a string/, 
        'Detects non-string implementation argument';
}

# Test rotation behavior
{
    # Set to built-in implementation
    set_min_rotation('built-in');
    
    # Test with various inputs
    is(min_rotation("A"), 0, 'Single character string returns 0');
    is(min_rotation("TAAA"), 1, 'Basic sequence rotated correctly');
    is(min_rotation("ACAACAAACAACACAAACAAACACAAC"), 14, 'More complex sequence rotated correctly');
    
    # Test with longer, more complex sequence
    my $long_seq = "TGCAACGTGCAACGT";
    my $result = min_rotation($long_seq);
    ok($result >= 0 && $result < length($long_seq), 
        'Rotation index within valid range');
}



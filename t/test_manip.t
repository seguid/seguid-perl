use strict;
use warnings;
use Test::More tests => 10;
use Test::Exception;

use_ok('SEGUID::Manip', qw(rotate reverse min_rotation_perl rotate_to_min));

# Test rotate
is(rotate("ABCDEFGH", 0), "ABCDEFGH", 'rotate by 0');
is(rotate("ABCDEFGH", 1), "BCDEFGHA", 'rotate by +1');
is(rotate("ABCDEFGH", 7), "HABCDEFG", 'rotate by +7');
is(rotate("ABCDEFGH", -1), "HABCDEFG", 'rotate by -1');
is(rotate("ABCDEFGH", 8), "ABCDEFGH", 'rotate by +8');

# Test reverse
is(reverse("ABCDEFGH"), "HGFEDCBA", 'reverse string');

# Test min_rotation_perl
is(min_rotation_perl("TAAA"), 1, 'min rotation of TAAA');
is(rotate("TAAA", min_rotation_perl("TAAA")), "AAAT", 'rotated TAAA');

# Test rotate_to_min
is(rotate_to_min("TAAA"), "AAAT", 'rotate to min of TAAA');

done_testing();

use strict;
use warnings;
use Test::More tests => 5;
use Test::Exception;

use_ok('SEGUID::Alphabet', 'tablefactory');

# Test basic pairs
is_deeply(
    tablefactory('AT,CG'),
    { 'A' => 'T', 'T' => 'A', 'C' => 'G', 'G' => 'C' },
    'Basic DNA pairs'
);

# Test protein alphabet
my $result = tablefactory('{protein}');
ok(exists $result->{A}, 'Protein alphabet contains A');
is(ref $result, 'HASH', 'Returns a hash reference');

# Test invalid specification
throws_ok(
    sub { tablefactory('ABC') },
    qr/Unknown alphabet specification/,
    'Throws error for invalid specification'
);
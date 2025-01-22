# SEGUID v2: Checksums for Linear, Circular, Single- and Double-Stranded Biological Sequences

This Perl package, seguid, implements SEGUID v2 together with the original SEGUID algorithm.

## Installation

To install this module, run the following commands:

```bash
perl Makefile.PL
make
make test
sudo make install
```

## Usage

From command line:
```bash
echo 'ACGT' | seguid --type=lsseguid
```

In Perl code:
```perl
use SEGUID qw(lsseguid csseguid ldseguid cdseguid seguidv1 seguidv1urlsafe);

my $checksum = lsseguid("ACGT");
```

## Function Types

| Topology  | Strandedness | Function  |
|-----------|--------------|-----------|
| linear    | single       | lsseguid  |
| circular  | single       | csseguid  |
| linear    | double       | ldseguid  |
| circular  | double       | cdseguid  |

## License

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

## Author

Gyorgy Babnigg <gbabnigg@gmail.com>

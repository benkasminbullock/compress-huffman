#!/home/ben/software/install/bin/perl
use warnings;
use strict;

# Turn an alphabet in the form of a hash from symbols to
# probabilities into a binary Huffman table.

use Compress::Huffman
my $cf = Compress::Huffman->new ();
$cf->symbols (\%symbols);
my $hufftable = $cf->{h};

# Turn an alphabet in the form of a hash from symbols to weights
# into a tertiary Huffman table.

$cf->symbols (\%symbols, size => 3, notprob => 1);


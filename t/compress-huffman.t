# This is a test for module Compress::Huffman.

use warnings;
use strict;
use Test::More;
use Compress::Huffman;
my $n = Compress::Huffman->new ();
ok ($n, "Made object");
my %s = (
    a => 1,
    b => 2,
    c => 3,
);
eval {
    $n->symbols (\%s, notprob => 1, verbose => 1);
};
ok (! $@, "Made symbol table");
done_testing ();
# Local variables:
# mode: perl
# End:

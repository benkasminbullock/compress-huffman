package Compress::Huffman;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw//;
%EXPORT_TAGS = (
    all => \@EXPORT_OK,
);
use warnings;
use strict;
use Carp;
use Scalar::Util 'looks_like_number';
use POSIX qw/ceil/;
our $VERSION = '0.01';

# eps is the allowed floating point error for summing the values of
# the symbol table to ensure they form a probability distribution.

use constant 'eps' => 0.0001;

# Private methods/functions

# Add the prefix $i to everything underneath us.

sub addcodetosubtable
{
    my ($fakes, $h, $k, $size, $i) = @_;
    my $subhuff = $fakes->{$k};
    for my $j (0..$size - 1) {
	my $subk = $subhuff->[$j];
	if ($subk =~ /^fake/) {
	    addcodetosubtable ($fakes, $h, $subk, $size, $i);
	}
	else {
	    $h->{$subk} = $i . $h->{$subk};
	}
    }
}

# Public methods below here

sub new
{
    return bless {};
}

sub symbols
{
    # Object and the table of symbols.
    my ($o, $s, %options) = @_;
    # Debugging output switch.
    my $verbose;
    if ($options{verbose}) {
	$verbose = 1;
    }
    # Check $s is a hash reference.
    if (ref $s ne 'HASH') {
	croak "Use as \$o->symbols (\\\%symboltable, options...)";
    }
    # Copy the symbol table into our own thing. We need to put extra
    # symbols in to it.
    my %c = %$s;
    $o->{c} = \%c;
    # The number of symbols we encode with this Huffman code.
    my $nentries = scalar keys %$s;
    if (! $nentries) {
	croak "Symbol table has no entries";
    }
    # Check we have numbers.
    for my $k (keys %$s) {
	if (! looks_like_number ($s->{$k})) {
	    croak "Non-numerical value '$s->{$k}' for key '$k'";
	}
    }
    if ($verbose) {
	print "Checked for numerical keys.\n";
    }
    my $size = $options{size};
    if (! defined $size) {
	$size = 2;
    }
    if ($size < 2 || int ($size) != $size) {
	croak "Bad size $size for Huffman table, must be integer >= 2";
    }
    if ($size > 10 && ! $options{alphabet}) {
	croak "Use \$o->symbols (\%t, alphabet => ['a', 'b',...]) for table sizes bigger than 10";
    }
    if ($verbose) {
	print "Set size of Huffman code alphabet to $size.\n";
    }
    # If this is supposed to be a probability distribution, check
    my $notprob = $options{notprob};
    if (! $notprob) {
	my $total = 0.0;
	for my $k (keys %$s) {
	    $total += $s->{$k};
	}
	if (abs ($total - 1.0) > eps) {
	    croak "Input values don't sum to 1.0; use \$o->symbols (\\\%s, notprob => 1) if not a probability distribution";
	}
	if ($verbose) {
	    print "Is a valid probability distribution (total = $total).\n";
	}
    }
    # The number of tables. We need $t - 1 pointers to tables, which
    # each require one table entry, so $t is the smallest number which
    # satisfies
    #
    # $t * $size >= $nentries + $t - 1

    my $t = ceil (($nentries -1) / ($size - 1));
    if ($verbose) {
	print "This symbol table requires $t Huffman tables of size $size.\n";
    }
    my $ndummies = 0;
    if ($size > 2) {
	# The number of dummy entries we need is
	my $ndummies = $t * ($size - 1) - $nentries + 1;
	if ($verbose) {
	    print "The Huffman tables need $ndummies dummy entries.\n";
	}
	if ($ndummies > 0) {
	    # Insert $ndummies dummy entries with probability zero into
	    # our copy of the symbol table.
	    for (0..$ndummies - 1) {
		my $dummy = "dummy$_";
		if ($c{$dummy}) {
		    croak "The symbol table already has an entry '$dummy'";
		}
		$c{$dummy} = 0.0;
	    }
	}
    }
    # The end-product, the Huffman encoding of the symbol table.
    my %h;
    my $nfake = 0;
    my %fakes;
    while ($nfake < $t) {
	if ($verbose) {
	    print "Making key list for sub-table $nfake / $t.\n";
	}
	my $total = 0;
	my @keys;

	# Find the $size keys with the minimum value and go through,
	# picking them out.

	for my $i (0..$size - 1) {
	    my $min = 'inf';
	    my $minkey;
	    for my $k (keys %c) {
		if ($c{$k} < $min) {
		    $min = $c{$k};
		    $minkey = $k;
		}
	    }
	    $total += $min;
	    if ($verbose) {
		print "Choosing $minkey with $min for symbol $i\n";
	    }
	    delete $c{$minkey};
	    push @keys, $minkey;
	    $h{$minkey} = $i;
	}
#	my @keys = sort {$c{$a} <=> $c{$b}} keys %c;
	# The total weight of this table.
	# The next table
	my @huff;
	for my $i (0..$size - 1) {
	    my $k = $keys[$i];
	    if (! defined $k) {
		last;
	    }
	    push @huff, $k;
	    if ($k =~ /^fake/) {
		addcodetosubtable (\%fakes, \%h, $k, $size, $i);
	    }
	}
	my $fakekey = 'fake'.$nfake;
	$c{$fakekey} = $total;
	$fakes{$fakekey} = \@huff;
	$nfake++;
    }
    if ($verbose) {
	print "Deleting dummy keys.\n";
    }
    for my $k (keys %h) {
	if ($k =~ /fake|dummy/) {
	    delete $h{$k};
	}
    }
    $o->{h} = \%h;
    $o->{s} = $s;
}

sub xl
{
    my ($o) = @_;
    my $h = $o->{h};
    my $s = $o->{s};
    die unless $h && $s;
    my $len = 0.0;
    for my $k (keys %$h) {
	$len += length ($h->{$k}) * $s->{$k};
	print "$k $h->{$k} $s->{$k} $len\n";
    }
    return $len;
}


1;

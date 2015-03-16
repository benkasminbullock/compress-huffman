=encoding UTF-8

=head1 NAME

Compress::Huffman - abstract here.

=head1 SYNOPSIS

    use Compress::Huffman;

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
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
our $VERSION = 0.01;

sub new
{
    return bless {};
}

sub symbols
{
    # Object and the table of symbols.
    my ($o, $s, %options) = @_;
    # Check $s is a hash reference.
    if (ref $s ne 'HASH') {
	croak "Use as \$o->symbols (\\\%symboltable, options...)";
    }
    # Check we have numbers.
    for my $k (keys %$s) {
	if (! looks_like_number ($s->{$k})) {
	    croak "Non-numerical value '$s->{$k}' for key '$k'";
	}
    }
    my $size = $options{size};
    if (! defined $size) {
	$size = 2;
    }
    if ($size < 2 || int ($size) != $size) {
	croak "Bad size $size for Huffman table, must be integer >= 2";
    }
    # If this is supposed to be a probability distribution, check
    my $notprob = $options{notprob};
    if (! $notprob) {
	my $total = 0.0;
	for my $k (keys %$s) {
	    $total += $s->{$k};
	}
	if (abs ($total - 1.0) > 0.0001) {
	    croak "Input values don't sum to 1.0; use \$o->symbols (\\\%s, notprob => 1) if not a probability distribution";
	}
    }
#    if ($size 
#	my $dummies = 	
}

1;

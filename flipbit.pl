#!/usr/bin/perl
#
# Initial script from StackExchange
# https://unix.stackexchange.com/questions/196251/change-only-one-bit-in-a-file
#
# Arguments
# [-r] [-B xxx -b xxx] -f <input_file>
#


use autodie;
use strict;
use utf8;
use warnings qw(all);
use bytes;

use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage qw(pod2usage);

# VERSION

=head1 SYNOPSIS

    flipbit [-r -s <n>] [-b <n>] -f file

=head1 OPTIONS

    Options:

    -r           flip random bit
    -s           seed for the RNG when choosing the random bit
    -b           index of bit to flip (starting from 0)
    -f           name of file where bit will be flipped
    -h           brief help
    -v           help, usage, and examples

  examples: 

  ./flipbit -r -f file
     flip one random bit in <file>

  ./flipbit -b 11 -f file
     flip bit 11 in <file>
 
=cut

GetOptions(
    q(r)                => \my $r,
    q(seed=i)           => \my $s,
    q(bit=i)            => \my $bit,
    q(file=s)           => \my $file,
    q(help)             => \my $help,
    q(verbose)          => \my $verbose,
) or pod2usage({ q(-verbose) => 1, q(-exitval) => 0 });

pod2usage(q(-verbose) => 0) if $help;
pod2usage(q(-verbose) => 1) if $verbose;

# Check file is defined
if (!defined $file) {
    pod2usage(q(-verbose) => 0);
}

# If bit is undefined, r flag must be defined
if (!(defined $bit) && !(defined $r)) {
    pod2usage(1);
}

# Set seed to 0 if undefined
if (!defined $s) {
    $s = 0;
}
srand($s);

# If bit to flipped is random, pick a random bit
my $fileSize = -1;
if (defined $r) {
    $fileSize = -s $file;
    $bit = 8 * int(rand($fileSize)) + int(rand(8));
}

# From file manipulation, set $B as the byte offset and $b as the bit offset (0-7)
my $B = $bit / 8;
my $b = $bit % 8;

my $byteToFlip;
open my $fh, '+<', $file                    or die "open failed; $!\n";
binmode $fh;

# Read the byte at location $B
seek($fh, $B, 0);
sysread($fh, $byteToFlip, 1) == 1       or die "read failed: $!\n";

# Unpack to char, flip bit, pack back to string
my $number = unpack ("c", $byteToFlip);
$number = $number ^ (1 << $b);
$byteToFlip = pack("c", $number);

# Write the byte at location $B
seek($fh, $B, 0);
syswrite($fh, $byteToFlip) == 1             or die "write failed: $!\n";
close $fh                                   or die "close failed: $!\n";
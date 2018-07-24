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

    flipbit [-r -s] [-B <n> -b <n>] -f file

=head1 OPTIONS

    Options:

    -r           flip random bit
    -s           seed for the RNG when choosing the random bit
    -B           index of byte where bit will be flipped (starting from 0)
    -b           index of bit within byte to flip (0-7)
    -f           name of file where bit will be flipped
    -h           brief help
    -v           help, usage, and examples

  examples: 

  ./flipbit -r -f file
     flip one random bit in <file>

  ./flipbit -B 1 -b 3 -f file
     flip bit 11 (1 * 8 + 3) in <file>
 
=cut

GetOptions(
    q(r)                => \my $r,
    q(seed=i)           => \my $s,
    q(Byte=i)           => \my $B,
    q(bit=i)            => \my $b,
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

# Byte and bit must either be both defined or both undefined
if ((defined $B) ^ (defined $b)) {
    pod2usage(1);
}

# If Byte (and bit) is undefined, r flag must be defined
if (!(defined $B) && !(defined $r)) {
    pod2usage(1);
}

# Set seed to 0 if undefined
if (!defined $s) {
    $s = 0;
}
print $s, "\n";
srand($s);

# If bit to flipped is random, pick a random byte and a random bit
if (defined $r) {
    my $fileSize = -s $file;
    $B = int(rand($fileSize));
    $b = int(rand(8));
}

print $B, "\n";
print $b, "\n";

my $byteToFlip;
open my $fh, '+<', $file                    or die "open failed; $!\n";
sysread($fh, $byteToFlip, 1, $B) == 1       or die "read failed: $!\n";
#$byteToFlip = $byteToFlip ^ (1 << $b);
seek($fh, $B, 0);
syswrite($fh, $byteToFlip) == 1             or die "write failed: $!\n";
close $fh                                   or die "close failed: $!\n";
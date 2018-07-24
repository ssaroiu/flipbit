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

    flipbit [-r -s] [-B <n> -b <n>] [file]

=head1 OPTIONS

    Options:

    -r           flip random bit
    -s           seed for the RNG when choosing the random bit
    -B           index of byte where bit will be flipped (starting from 0)
    -b           index of bit within byte to flip (0-7)
    -h           brief help
    -v           help, usage, and examples

  examples: 

  ./flipbit -r <file>
     prints the contents of <file> with one random bit flipped

  ./flipbit -B 1 -b 3 <file>
     prints the content of <file> with bit 11 (1 * 8 + 3) flipped
 
=cut

GetOptions(
    q(r)                => \my $r,
    q(seed)             => \my $s,
    q(Byte=i)           => \my $B,
    q(bit=i)            => \my $b,
    q(help)             => \my $help,
    q(verbose)          => \my $verbose,
) or pod2usage({ q(-verbose) => 1, q(-exitval) => 0 });

pod2usage(q(-verbose) => 0) if $help;
pod2usage(q(-verbose) => 1) if $verbose;

# Byte and bit must either be both defined or both undefined
if ((defined $B) ^ (defined $b)) {
    pod2usage(1);
}


# If Byte (and bit) is undefined, r flag must be defined
if (!(defined $B) && !(defined $r)) {
    pod2usage(1);
}

# Set the seed if defined
if (defined $s) {
    srand($s);
}

open my $file, "<:raw", "$file";

# if (defined $r) {
#     my $fileSize = -s $file;
#     my $offset = int(rand($fileSize));
#     $B = int($offset  / 8);
#     $b = $offset % 8;
# #    print "$fileSize";
#     die "done";
# }

#substr($file,$B,1) = substr($file,$B,1) ^ chr(1<<$b); 

close $file;
print $file;

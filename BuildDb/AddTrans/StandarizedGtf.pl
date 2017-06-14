#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;

&usage if @ARGV<1;

sub usage {
        my $usage = << "USAGE";

        Reformat iseeRNA result(gtf) to standard gtf format.
        https://genome.ucsc.edu/FAQ/FAQformat.html#format4
        Author: zhoujj2013\@gmail.com
        Usage: $0 iseeRNA.gtf > new.gtf

USAGE
print "$usage";
exit(1);
};

my $gtf_f = shift;

open IN,"$gtf_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$t[8] =~ s/;$//g;
	my @t8 = split /; /,$t[8];
	my @new;
	foreach my $e (@t8){
		$e =~ s/ / "/g;
		$e =~ s/$/"/g;
		push @new,$e;
	}
	$t[8] = join "; ",@new;
	print join "\t",@t;
	print "\n";
}
close IN;

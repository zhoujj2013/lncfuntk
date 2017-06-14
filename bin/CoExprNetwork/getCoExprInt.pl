#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use File::Path qw(make_path);
use Data::Dumper;
use Cwd qw(abs_path);

&usage if @ARGV<1;

sub usage {
        my $usage = << "USAGE";

        This script designed for generate coexpress interaction.
        Author: zhoujj2013\@gmail.com 
        Usage: $0 cutoff expr.txt

USAGE
print "$usage";
exit(1);
};

my ($cutoff, $expr_f) = @ARGV;

open IN,"$expr_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	#awk '{if($3 >= 0.95 || $3 <= -0.95){print $1"\t"$2"\tgg\tNA\tco-express";}}' test/mESC_CM.PearsonR.lst > mESCsCoExpression.txt
	my $r = abs($t[2]);
	if($r >= $cutoff){
		print "$t[0]\t$t[1]\tgg\tNA\tco-express\n";
	}
}
close IN;

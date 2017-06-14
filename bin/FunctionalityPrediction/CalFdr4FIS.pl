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

        This script designed for FIS FDR calculation.
        Author: zhoujj2013\@gmail.com 
        Usage: $0 config.cfg

USAGE
print "$usage";
exit(1);
};

my $fis_list_f = shift;

my $num = `wc -l $fis_list_f | awk '{print \$1}'`;
chomp($num);

my $cutoff_num = int($num * 0.05);


# sort the score
my @score;
open IN,"$fis_list_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	push @score,$t[-1];
}
close IN;

my @score_sorted = sort {$b <=> $a} @score;

my $i = 1;
foreach my $s (@score_sorted){
	if($i eq $cutoff_num){
		print "$s";
	}
	$i++;
}

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

        This script design for filtering low expressed genes in the first column and make fpkm < 0.01 to 0.01.
        Author: zhoujj2013\@gmail.com
        Usage: $0 cutoff xx.expr.mat

USAGE
print "$usage";
exit(1);
};

my $cutoff = shift;
my $expr_f = shift;

my %geneid;
open IN,"$expr_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my $id = shift @t;
	my $primary_sample=$t[0];
	if($primary_sample >= $cutoff){
		foreach(my $i=0; $i < scalar(@t); $i++){
			if($t[$i] < 0.01){
				$t[$i] = 0.01;
			}
		}
		$geneid{$id} = \@t;
	}
}
close IN;


#print Dumper(\%geneid);
#print join "\t",@header;
#print "\n";
foreach my $g (keys %geneid){
	my $flag = 0;
	foreach my $s (@{$geneid{$g}}){
		if($s > 0.01){
			$flag = 1;
		}
	}
	if($flag == 1){
		print "$g\t";
		print join "\t",@{$geneid{$g}};
		print "\n";
	}
}


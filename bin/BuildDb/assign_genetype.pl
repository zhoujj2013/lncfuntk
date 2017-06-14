#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;

&usage if @ARGV<1;

#open IN,"" ||die "Can't open the file:$\n";
#open OUT,"" ||die "Can't open the file:$\n";

sub usage {
        my $usage = << "USAGE";

        Assign biotype to each genes.
        Author: zhoujj2013\@gmail.com
        Last modified: Fri May 26 12:06:42 HKT 2017

        Example:perl $0 refGene.txt annotation_file_from_ncbi.txt

USAGE
print "$usage";
exit(1);
};

my $refgene_f = shift;
my $refgene_anno_f = shift;

my %ref;
my %len;

open IN,"$refgene_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	
	push @{$ref{$t[12]}},$t[1];
	
	# get length
	my $exonNum = $t[8];
	my @exonStarts = split /,/,$t[9];
	my @exonEnds = split /,/,$t[10];
	my $l = 0;
	for( my $i = 0; $i < $exonNum; $i++){
		$l = $l + $exonEnds[$i] - $exonStarts[$i];
	}
	$len{$t[1]} = $l;
}
close IN;

#print Dumper(\%ref);

my %anno;
open IN,"$refgene_anno_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$anno{$t[0]} = $t[1];
}
close IN;
#print Dumper(\%anno);

foreach my $k (keys %ref){
	my $flag = 1;
	my @biotypeArr;
	my @leng;
	foreach my $transid (@{$ref{$k}}){
		push @leng,$len{$transid};
		if(exists $anno{$transid}){
			push @biotypeArr,$anno{$transid};
			if($anno{$transid} !~ /(antisense_RNA|lncRNA|unclassified)/){
				$flag = 0;
			}
		}else{
			print STDERR "$k\t$transid\tNot found in NCBI .gbff files\n";
		}
	}
	
	my @leng_sorted = sort {$a <=> $b} @leng;
	my $max_length = $leng_sorted[-1];
	# output biotype
	if($flag == 1){
		# only 2 gene less than 200bp
		# so I elimilate the filtering
		#if($max_length > 200){
			print "$k\tlncRNA\t";
		#}else{
		#	print "$k\tsmall noncoding RNA\t";
		#}
		print join ",",@{$ref{$k}};
		print "\n";
	}elsif($flag == 0){
		my $biotype = "";
		my $biotypeStr = join ",",@biotypeArr;
		if($biotypeStr =~ /protein coding gene/){
			$biotype = "protein coding gene";
		}elsif($biotypeStr =~ /miRNA/){
			$biotype = "miRNA";
		}elsif($biotypeStr =~ /rRNA/){
			$biotype = "rRNA";
		}elsif($biotypeStr =~ /snoRNA/){
			$biotype = "snoRNA";
		}elsif($biotypeStr =~ /snRNA/){
			$biotype = "snRNA";
		}elsif($biotypeStr =~ /pseudogene/){
			$biotype = "pseudogene";
		}else{
			$biotype = "otherRNA";
		}
		print "$k\t$biotype\t";
		print join ",",@{$ref{$k}};
		print "\n";
	}
}

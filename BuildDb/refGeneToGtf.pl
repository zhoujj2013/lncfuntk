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

        Description of this script.
        Author: zhoujj2013\@gmail.com
        Usage: $0 <para1> <para2>
        Example:perl $0 para1 para2

USAGE
print "$usage";
exit(1);
};

my $refgene_f = shift;

my %bed;
open IN,"$refgene_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	push @{$bed{$t[12]}},\@t;
}
close IN;

foreach my $k (keys %bed){
	my $geneid = "$k";
	my %mrnaid;
	foreach my $t (@{$bed{$k}}){
		#print Dumper($t);
		my $chr = $t->[2];
		my $s = $t->[4];
		my $e = $t->[5];
		my $strand = $t->[3];
		
		my $blockNum = $t->[8];
		my @blockStarts = split /,/,$t->[9];
		my @blockEnds = split /,/,$t->[10];
		
		my $transid = "";
		if(exists $mrnaid{$t->[1]}){
			$transid = "$t->[1]-$mrnaid{$t->[1]}";
		}else{
			$transid = "$t->[1]";
		}
		
		for(my $j = 0; $j < $blockNum; $j++){
			my $start = $blockStarts[$j];
			my $end = $blockEnds[$j];
			# for 0-base coordinate system
			$start = $start + 1;
			print "$chr\ttranscript\texon\t$start\t$end\t.\t$strand\t.\ttranscript_id \"$transid\"; gene_id \"$geneid\"; gene_name \"$geneid\";\n"; 
		}
		$mrnaid{$t->[1]}++;
	}
}

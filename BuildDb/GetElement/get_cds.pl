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

        Get CDS region from refGene.txt
        Author: zhoujj2013\@gmail.com
        Usage: $0 refGene.txt

USAGE
print "$usage";
exit(1);
};


my $refgene_f = shift;

open IN,"$refgene_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	next if($t[1] =~ /^NR/);
	
	my $cdsStart = $t[6];
	my $cdsEnd = $t[7];
	my $exonNum = $t[8];

	my @exonStart = split /,/,$t[9];
	my @exonEnd = split /,/,$t[10];
	
	my $flag = 0;
	for(my $i = 0; $i < $exonNum; $i++){
		if($exonEnd[$i] < $cdsStart){
			next;
		}elsif($exonStart[$i] <= $cdsStart && $exonEnd[$i] >= $cdsEnd){
			print "$t[2]\t$cdsStart\t$cdsEnd\t$t[1]\t$t[12]\t$t[3]\n";
			last;
		}elsif($exonEnd[$i] >= $cdsStart && $flag == 0){
			print "$t[2]\t$cdsStart\t$exonEnd[$i]\t$t[1]\t$t[12]\t$t[3]\n";
			$flag++;
		}elsif($exonEnd[$i] >= $cdsEnd && $flag == 1){
			print "$t[2]\t$exonStart[$i]\t$cdsEnd\t$t[1]\t$t[12]\t$t[3]\n";
			$flag++;
		}elsif($flag == 1){
			print "$t[2]\t$exonStart[$i]\t$exonEnd[$i]\t$t[1]\t$t[12]\t$t[3]\n";
		}
	}
}
close IN;

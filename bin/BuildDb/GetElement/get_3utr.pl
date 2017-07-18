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

        Get 3utr from refGene.txt
        Author: zhoujj2013\@gmail.com
        Usage: $0 <refGene.txt>

USAGE
print "$usage";
exit(1);
};

my $refgene_f = shift;

my %transid;

open IN,"$refgene_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	next if($t[1] =~ /^NR/);
	next if($t[2] =~ /_/);
	
	my $cdsStart = $t[6]-1; # to UTR start and end
	my $cdsEnd = $t[7];
	my $exonNum = $t[8];
	
	my @exonStart = split /,/,$t[9];
	my @exonEnd = split /,/,$t[10];
	
	next if(exists $transid{$t[1]});
	$transid{$t[1]} = 1;
	
	if($t[3] eq "+"){
		next if($cdsEnd eq $exonEnd[-1]);
		for(my $i = $exonNum - 1; $i >= 0; $i--){
			if($cdsEnd == $exonEnd[$i]){
				last;
			}elsif($cdsEnd > $exonStart[$i] && $cdsEnd <= $exonEnd[$i]){
				print "$t[2]\t$cdsEnd\t$exonEnd[$i]\t$t[1]\t$t[12]\t$t[3]\n";
				last;
			}elsif($cdsEnd <= $exonStart[$i]){
				print "$t[2]\t$exonStart[$i]\t$exonEnd[$i]\t$t[1]\t$t[12]\t$t[3]\n";
			}
		}
	}elsif($t[3] eq "-"){
		next if($cdsStart eq $exonStart[-1]);
		for(my $i = 0; $i < $exonNum; $i++){
			if($cdsStart + 1 == $exonStart[$i]){
				last;
			}elsif($cdsStart < $exonEnd[$i] && $cdsStart >= $exonStart[$i]){
				my $trueStart = $cdsStart + 1;
				print "$t[2]\t$exonStart[$i]\t$trueStart\t$t[1]\t$t[12]\t$t[3]\n";
				last;
			}elsif($cdsStart >= $exonEnd[$i]){
				#my $trueEnd = $exonEnd[$i] + 1;
				print "$t[2]\t$exonStart[$i]\t$exonEnd[$i]\t$t[1]\t$t[12]\t$t[3]\n";
			}
		}
	}
}
close IN;

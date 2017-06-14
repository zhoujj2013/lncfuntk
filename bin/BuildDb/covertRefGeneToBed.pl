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

my %ref;
my %trans;
open IN,"$refgene_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$trans{$t[1]} = [$t[2],$t[4],$t[5],$t[3]];
	push @{$ref{$t[12]}},$t[1];
}
close IN;

foreach my $k (keys %ref){
	my @len;
	foreach my $rna (@{$ref{$k}}){
		my $len = $trans{$rna}[2] - $trans{$rna}[1];
		push @len,[$rna, $len];
	}
	my @len_sorted = sort {$a->[1] <=> $b->[1]} @len;
	my $refTrans = $len_sorted[0][0];
	print "$trans{$refTrans}[0]\t$trans{$refTrans}[1]\t$trans{$refTrans}[2]\t$k\t0\t$trans{$refTrans}[3]\n";
}



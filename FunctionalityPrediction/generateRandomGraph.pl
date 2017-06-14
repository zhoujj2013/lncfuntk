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

        Generate random network for FIS cutoff determination.
        Author: zhoujj2013\@gmail.com 
        Last modified: Wed Apr 19 10:48:09 HKT 2017
        Usage: perl $0 XX.node.degree.txt XX.int pretrained_weight_value.txt

USAGE
print "$usage";
exit(1);
};

my $geneList_f = shift;
my $int_f = shift;
my $weight_f = shift;
my $prefix = "lncFunNet";

my $num = `wc -l $geneList_f | awk '{print \$1}'`;
chomp($num);

my $total_edge = `wc -l $int_f | awk '{print \$1}'`;
chomp($total_edge);

my $edge_assign = int($total_edge/$num);

print STDERR "Node count: $num\nTotal edge: $total_edge\nedge need assign: $edge_assign\n";

mkdir "./$prefix.randGraph" unless(-e "./$prefix.randGraph");

# generate a sequence of num 
foreach my $i (1 .. 100){
	print STDERR "permute $i\n";
	my @index;
	my %index;
	while(scalar(@index) < $num){
		#print STDERR scalar(@index),"\n";
		my $n = int(rand($num));
		unless(exists $index{$n}){
			$index{$n} = 1;
			push @index,$n;
		}
	}

	print STDERR "generate number finished\n";
	my %num2gene;
	my $j = 0;
	open IN,"$geneList_f" || die $!;
	while(<IN>){
		chomp;
		my @t = split /\t/;
		$num2gene{$index[$j]} = $t[0];
		$j++;
	}
	close IN;
	
	`python $Bin/randomSFGraph.py $num $edge_assign 0 > ./$prefix.randGraph/$prefix.$i.rd.txt`;
	print STDERR "generate graph finished\n";
	open OUT,">","./$prefix.randGraph/$prefix.$i.final.txt" || die $!;
	open IN,"./$prefix.randGraph/$prefix.$i.rd.txt" || die $!;
	while(<IN>){
		chomp;
		my @t = split /\t/;
		my $a = $num2gene{$t[0]};
		my $b = $num2gene{$t[1]};
		#if(!(exists $num2gene{$t[1]}) || !(exists $num2gene{$t[0]})){
		#	print "$t[0]\t$t[1]\n";
		#}
		
		print OUT "$a\t$b\tgg\t0\trandom\n";
	}
	close IN;
	close OUT;
	`perl $Bin/StatNetworkDegree.pl ./$prefix.randGraph/$prefix.$i.final.txt $geneList_f > ./$prefix.randGraph/$prefix.$i.Degree.stat 2>./$prefix.randGraph/$prefix.$i.Neighbor.stat`;
	`grep -v \"^#\" ./$prefix.randGraph/$prefix.$i.Neighbor.stat | grep "lncRNA" > ./$prefix.randGraph/$prefix.$i.Neighbor.stat.cl`;
	`cut -f 2,3,4 ./$prefix.randGraph/$prefix.$i.Neighbor.stat.cl > ./$prefix.randGraph/$prefix.$i.Neighbor.stat.cl2`;
	`python $Bin/ScaleMaxMin.py ./$prefix.randGraph/$prefix.$i.Neighbor.stat.cl2 > ./$prefix.randGraph/$prefix.$i.Neighbor.stat.nor`;
	`python $Bin/CalFIS.py ./$prefix.randGraph/$prefix.$i.Neighbor.stat.nor $weight_f > ./$prefix.randGraph/$prefix.$i.result`;
	print STDERR "permute $i finished\n";
}
 

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

        This script designed for change miranda coordinate to 0-based coordinate.
        Author: zhoujj2013\@gmail.com
        Usage: $0 <miranda_result> <clip_cluster_bed> <strand: plus/minus>

USAGE
print "$usage";
exit(1);
};

my $miranda_result = shift;  # miranda output
my $chip_bed_f = shift;      # chip-seq binding bed file
my $strand = shift;          # minus or plus

# mmu-miR-15b-5p^IENSMUST00000027337^I150.00^I-18.88^I2 20^I544 566^I19^I73.68%^I84.21%

my %cluster;
open IN,"$chip_bed_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$cluster{$t[3]} = [$t[0], $t[1], $t[2]];
}
close IN;

#print Dumper(\%cluster);

# change to origin coordinate
my $i = "0000001";
my %out;
open IN,"$miranda_result" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my $cl_id;
	# plus and minus id
	if($strand eq "plus"){
		$cl_id = $t[1];
	}elsif($strand eq "minus"){
		$cl_id = $1 if($t[1] =~ /(.*)_rc/);
	}
	
	my $mir = $t[0];
	my @coor = split / /,$t[5];
	#print "$coor[0]\t$coor[1]\n";
	
	my $orgin_s = $cluster{$cl_id}->[1];
	my $orgin_e = $cluster{$cl_id}->[2];
	my $orgin_chr = $cluster{$cl_id}->[0];
#	print "$orgin_s\t$orgin_e\n";
	
	my $record_id = "$t[0]\_$cl_id\_$strand\_$i";
	# plus, 0-based coordinate
	if($strand eq "plus"){
		my $s = $orgin_s + $coor[0] - 1;
		my $e = $s + ($coor[1] - $coor[0] + 1) - 1;
		push @{$out{$orgin_chr}}, [$orgin_chr,$s,$e,$record_id,1000,"+"];
	# minus, 0-based coordinate
	}elsif($strand eq "minus"){
		my $e = $orgin_e - $coor[0] + 1;
		my $s = $e - ($coor[1] - $coor[0] + 1) + 1;
		push @{$out{$orgin_chr}}, [$orgin_chr,$s,$e,$record_id,1000,"+"];
		#print "$s\t$e\n";
	}
	$i++;
}
close IN;

foreach my $chr (sort keys %out){
	my @out_sorted = sort {$a->[1] <=> $b->[1]} @{$out{$chr}};
	foreach(@out_sorted){
		print join "\t",@{$_};
		print "\n";
	}
}


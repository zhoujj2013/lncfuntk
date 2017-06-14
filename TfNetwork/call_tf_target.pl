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

        This script designed for find TF target genes by ChIP-seq data.
        Author: zhoujj2013\@gmail.com 
        Usage: $0 TFname up_stream down_stream TF_binding_peaks.bed GeneRegion.bed GeneRegion.anno

USAGE
print "$usage";
exit(1);
};

my $tf_name = shift;
my $up = shift;
my $down = shift;
my $binding_f = shift;
my $generegion_f = shift;
my $anno_f = shift;

my %gene;
open OUT,">","./gene.tss.$up.$down.extend" || die $!;
open IN,"$generegion_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$gene{$t[3]} = \@t;
	my $strand = $t[5];
	if($strand eq "+"){
		my $s = $t[1] - $up;
		$s =0 if($s < 0);
		my $e = $t[1] + $down;
		print OUT "$t[0]\t$s\t$e\t$t[3]\n";
	}elsif($strand eq "-"){
		my $e = $t[2] + $up;
		my $s = $t[2] - 1 - $down;
		$s = 0 if($s < 0);
		print OUT "$t[0]\t$s\t$e\t$t[3]\n";
	}
}
close IN;
close OUT;

`$Bin/../BEDTools/bin/intersectBed -a $binding_f -b ./gene.tss.$up.$down.extend -wo > ./intersect.bed`;

my %gene2mir;
open OUT1,">","./miRNA.bed" || die $!;
open OUT2,">","./otherGenes.bed" || die $!;
open IN,"$anno_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if($t[1] eq "miRNA"){
		print OUT1 join "\t",@{$gene{$t[0]}};
		print OUT1 "\n";
	}else{
		next unless(exists $gene{$t[0]});
		print OUT2 join "\t",@{$gene{$t[0]}};
		print OUT2 "\n";
	}
}
close IN;
close OUT1;
close OUT2;

`$Bin/../BEDTools/bin/intersectBed -a ./otherGenes.bed -b ./miRNA.bed -wo > ./miRNA.others.bed`;

open IN,"./miRNA.others.bed" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$gene2mir{$t[3]}{$t[9]} = 1;
}
close IN;

#print Dumper(\%gene2mir);

my %tf2gene;
open IN,"./intersect.bed" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$tf2gene{$t[3]}{$t[7]} = "$tf_name\t$t[7]\tpd\tNA\tTF_binding\n";
	if(exists $gene2mir{$t[7]}){
		foreach my $mir (keys %{$gene2mir{$t[7]}}){
			$tf2gene{$t[3]}{$mir} = "$tf_name\t$mir\tpd\tNA\tTF_binding;within_transcript\n";
		}
	}
}
close IN;

foreach my $tf (keys %tf2gene){
	foreach my $geneid (keys %{$tf2gene{$tf}}){
		print "$tf2gene{$tf}{$geneid}";
	}
}



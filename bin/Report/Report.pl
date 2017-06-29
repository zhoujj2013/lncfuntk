#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use File::Path qw(make_path);
use Data::Dumper;
use Cwd qw(abs_path);
use lib $Bin;

use JSON;

&usage if @ARGV<1;

sub usage {
        my $usage = << "USAGE";

        This script create report for lncFNTK analysis
        Author: zhoujj2013\@gmail.com 
        Last modified: Thu May 25 11:23:16 HKT 2017
        Usage: $0 config.txt

USAGE
print "$usage";
exit(1);
};

my $conf = shift;

my %conf;
&load_conf($conf, \%conf);

my $outdir = abs_path("../");

$conf{OUTDIR} = $outdir;

# The input file information
open OUT,">","./input.json" || die $!;
print OUT encode_json \%conf;
close OUT;

# Functional lncRNA list Top 10
`less ../06FunctionalAnnotation/lncFunNet.GO.enrich.result.txt | sort -k2nr > FunctionalLncRNA.txt`;

my %top5;
my %go;
my %lncrna;
$lncrna{"data"} = [];

my $i = 1;
open IN,"./FunctionalLncRNA.txt" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my @row = @t[0 .. 6];
	$row[1] = sprintf("%.3f",$row[1]);
	$row[4] = sprintf("%.3e",$row[4]);
	$row[5] = sprintf("%.3e",$row[5]);
	push @{$lncrna{"data"}}, \@row;
	$top5{$t[0]} = \@row if($i <= 5);
	my $go_id = "$t[2]:$t[3]";
	$go{$go_id}++;
	$i++;
}
close IN;


open OUT,">","./lncrna.json" || die $!;
print OUT encode_json \%lncrna;
close OUT;

# Functional lncRNA annotation result(population)
my %goTop10;
$goTop10{"categories"} = [];
$goTop10{"name"} = "Percentage(%)";
$goTop10{"data"} = [];
my @sorted_go = sort {$go{$a} <=> $go{$b}} keys %go;
my $j = 1;
foreach my $gid (@sorted_go){
	last if($j > 10);
	push @{$goTop10{"categories"}},$gid;
	my $go_percentage = ($go{$gid}/($i-1))*100;
	$go_percentage = sprintf("%.3f",$go_percentage);
	#print "$go_percentage\n";
	push @{$goTop10{"data"}},$go_percentage*1;
	$j++;
}

# output barchart data
open OUT,">","./gotop10.json" || die $!;
print OUT encode_json \%goTop10;
close OUT; 

# Integrate regulatory network demo
`cp ../04NetworkConstruction/04NetworkStat/mESCs.int.txt GeneRegulatoryNetwork.interaction.txt`;

# a program to get lncRNA subnetwork
# cp gene type file to get type information
my %type;
open IN,"../04NetworkConstruction/$conf{PREFIX}.geneexpr.lst" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$type{$t[0]} = $t[1];
}
close IN;

my %nodes;
open IN,"./GeneRegulatoryNetwork.interaction.txt" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if(exists $top5{$t[0]} or exists $top5{$t[1]}){
		if($type{$t[0]} ne "pcg"){
			$nodes{$t[0]} = 1;
		}
		if($type{$t[1]} ne "pcg"){
			$nodes{$t[1]} = 1;
		}
	}
}
close IN;

open OUT,">","./top5_target_node.lst" || die $!;
foreach my $n (keys %nodes){
	print OUT "$n\n";
}
close OUT;

#print "python $Bin/GetSubnetwork.py ../04NetworkConstruction/04NetworkStat/$conf{PREFIX}.network.pickle ./top5_target_node.lst $conf{PREFIX}\n";
`python $Bin/GetSubnetwork.py ../04NetworkConstruction/04NetworkStat/$conf{PREFIX}.network.pickle ./top5_target_node.lst $conf{PREFIX}`;
#print "python $Bin/ToJson.py $conf{PREFIX}.int.txt $conf{PREFIX}.node.degree.txt $conf{PREFIX}\n";
`python $Bin/ToJson.py $conf{PREFIX}.int.txt $conf{PREFIX}.node.degree.txt $conf{PREFIX}`;
#print "python $Bin/CreateD3Html.py $conf{PREFIX}.sn.json $conf{PREFIX}\n";
#`python $Bin/CreateD3Html.py $conf{PREFIX}.sn.json $conf{PREFIX}`;

`cp $Bin/index.html .`;
`cp $Bin/nodeLegend.png .`;

#########################
sub load_conf
{
    my $conf_file=shift;
    my $conf_hash=shift; #hash ref
    open CONF, $conf_file || die "$!";
    while(<CONF>)
    {
        chomp;
        next unless $_ =~ /\S+/;
        next if $_ =~ /^#/;
        #warn "$_\n";
        my @F = split"\t", $_;  #key->value
        $conf_hash->{$F[0]} = $F[1];
    }
    close CONF;
}

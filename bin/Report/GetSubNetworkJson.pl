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

        This script designed for retriving subnetwork from lncFunNet produced network.
        Author: zhoujj2013\@gmail.com 
        Last modified: Tue Sep 26 21:55:53 HKT 2017
        Usage: $0 GeneRegulatoryNetwork.interaction.txt mESCs.Node.Type.Degree.txt selected.note.lst > sn.json

USAGE
print "$usage";
exit(1);
};

my $nw_f = shift;
my $nodeType_f = shift;
my $selectedNodes_f = shift;

my %keyNodes;
my $i = 1;
open IN,"$selectedNodes_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$keyNodes{$t[0]}{'id'} = sprintf("%s",$i);
	$keyNodes{$t[0]}{'degree'} = 0;
	$i++;
}
close IN;

my %nodetype;
open IN,"$nodeType_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$nodetype{$t[0]} = $t[2];
}
close IN;

my %nw;
open IN,"$nw_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if(exists $keyNodes{$t[0]} and exists $keyNodes{$t[1]}){
		next if($nodetype{$t[0]} eq "miRNA" and $nodetype{$t[0]} eq "miRNA");
		$nw{$t[0]}{$t[1]} = 1;
		$keyNodes{$t[0]}{'degree'} = $keyNodes{$t[0]}{'degree'} + 1;
		$keyNodes{$t[1]}{'degree'} = $keyNodes{$t[1]}{'degree'} + 1;
	}
}
close IN;

#print Dumper(\%keyNodes);

my %out;
## nodes

$out{'nodes'} = [];
foreach my $k (keys %keyNodes){	
	my %node;
	next if($keyNodes{$k}{'degree'} == 0);
	$node{'id'} = $keyNodes{$k}{'id'};
	$node{'value'} = "".$keyNodes{$k}{'degree'};
	$node{'label'} = $k;
	if($nodetype{$k} eq 'TF'){
		$node{'color'} = {
			"background" => "rgba(244,177,131,1)",
			"border" => "gray",
			"highlight" => {
				"background" => "rgba(244,177,131,1)"
			}
		};
	}elsif($nodetype{$k} eq 'lncRNA'){
		$node{'color'} = {
			"background"=>"rgba(255,102,255,1)", 
			"border"=>"gray",
			"highlight"=>{
				"background"=>"rgba(255,102,255,1)"
			}
		};
	}elsif($nodetype{$k} eq 'miRNA'){
		$node{'color'} = {
			"background"=>"rgba(146,208,80,1)",
			"border"=>"gray",
			"highlight"=>{
				"background"=>"rgba(146,208,80,1)"
			}
		};
	}else{
		$node{'color'} = {
			"background"=>"cyan",
			"border"=>"gray",
			"highlight"=>{
				"background"=>"cyan"
			}
		};
	}
	push @{$out{'nodes'}},\%node;
}

#print JSON->new->pretty->encode(\%out);
$out{'edges'} = [];
foreach my $k1 (keys %nw){
	foreach my $k2 (keys %{$nw{$k1}}){
		next if($nodetype{$k1} eq "miRNA" and $nodetype{$k2} eq "miRNA");
		my %edge;
		$edge{'from'} = $keyNodes{$k1}{'id'};
		$edge{'to'} = $keyNodes{$k2}{'id'};
		push @{$out{'edges'}},\%edge;
	}
}

print JSON->new->pretty->encode(\%out);


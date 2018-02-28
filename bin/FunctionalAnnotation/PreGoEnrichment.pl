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

        This script designed for hub gene informative score (iscore) calculation.
        Author: zhoujj2013\@gmail.com
        Usage: $0 <interaction_f> <go annotation_f> <element_type_f> <functional_lncRNA.lst>

USAGE
print "$usage";
exit(1);
};

my ($inter_f, $gene2go_f, $gtype_f, $func_lncrna_f) = @ARGV;

# read in interaction file
my %inter;
open IN,"$inter_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$inter{$t[0]}{$t[1]} = 1;
}
close IN;

# read in go annotation file
my %gene2go;
open IN,"$gene2go_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my $gene_name = shift @t;
	next if($t[0] eq "NA");
	$gene2go{$gene_name} = \@t;
}
close IN;

# read in gene type file
my %mgiType;
#my %ensemblType;
#my %mgi2ensembl;
open IN,"$gtype_f" || die $!;
while(<IN>){
    chomp;
	my @t = split /\t/;
	$mgiType{$t[0]} = $t[1];
#	$ensemblType{$t[1]} = $t[2];
#	$mgi2ensembl{$t[0]} = $t[1];
}
close IN;

my %phub;
# Traverse hash
# find lncRNAs
my %node;
foreach my $k1 (sort keys %inter){
	foreach my $k2 (sort keys %{$inter{$k1}}){
			push @{$node{$k1}},$k2;
			push @{$node{$k2}},$k1;
			#if($mgiType{$k1} eq $HubType && $mgiType{$k2} ne $HubType){
			#	push @{$lncrna{$k1}},$k2;
			#}elsif($mgiType{$k1} ne $HubType && $mgiType{$k2} eq $HubType){
			#	push @{$lncrna{$k2}},$k1;
			#}elsif($mgiType{$k1} eq $HubType && $mgiType{$k2} eq $HubType){
			#	push @{$lncrna{$k1}},$k2;
			#	push @{$lncrna{$k2}},$k1;
			#}
	}
}

# remove duplication
foreach my $k (keys %node){
	my @arr = @{$node{$k}};
	my $arr_rm = remove_duplicate(\@arr);
	$node{$k} = $arr_rm;
}

# count
foreach my $k1 (sort keys %node){
	next unless($mgiType{$k1} eq 'lncRNA');
	my @go;
	foreach my $k2 (@{$node{$k1}}){
		$phub{$k1}{'lncrna'}++ if($mgiType{$k2} eq 'lncRNA');
		$phub{$k1}{'pcg'}++ if($mgiType{$k2} eq 'pcg');
		$phub{$k1}{'tf'}++ if($mgiType{$k2} eq 'TF');
		$phub{$k1}{'mirna'}++ if($mgiType{$k2} eq 'miRNA');
		push @go,@{$gene2go{$k2}} if(exists $gene2go{$k2});
	}
	my $go_rmdup = remove_duplicate(\@go);
	$phub{$k1}{'go'} = scalar(@{$go_rmdup});
}
#print Dumper(\%phub);

# remove duplication
sub remove_duplicate{
    my ($arr) = shift;
    my %h;
    foreach(@$arr){
        $h{$_} = 1;
    }
    my @array;
    foreach my $k (keys %h){
        push @array,$k;
    }
    return \@array;
}

# calculate mean value
my $lncrna_sum = 0;
my $pcg_sum = 0;
my $tf_sum = 0;
my $mirna_sum = 0;
my $go_sum = 0;


my $lncrna_max = 0;
my $pcg_max = 0;
my $tf_max = 0;
my $mirna_max = 0;
my $go_max = 0;

my $lncrna_min = 10000;
my $pcg_min = 10000;
my $tf_min = 10000;
my $mirna_min = 10000;
my $go_min = 10000;

#my $lncrna_num = 0;
#my $pcg_num = 0;
#my $tf_num = 0;
#my $mirna_num = 0;
#my $go_num = 0;

#print Dumper(\%phub);

foreach my $g (keys %phub){
	
	$lncrna_sum += $phub{$g}{'lncrna'} if(exists $phub{$g}{'lncrna'});
	$lncrna_max = $phub{$g}{'lncrna'} if(exists $phub{$g}{'lncrna'} && $phub{$g}{'lncrna'} > $lncrna_max);
	$lncrna_min = $phub{$g}{'lncrna'} if(exists $phub{$g}{'lncrna'} && $phub{$g}{'lncrna'} < $lncrna_min);
	#$lncrna_num++ if(exists $phub{$g}{'lncrna'});
	
	$pcg_sum += $phub{$g}{'pcg'} if(exists $phub{$g}{'pcg'});
	$pcg_max = $phub{$g}{'pcg'} if(exists $phub{$g}{'pcg'} && $phub{$g}{'pcg'} > $pcg_max);
	$pcg_min = $phub{$g}{'pcg'} if(exists $phub{$g}{'pcg'} && $phub{$g}{'pcg'} < $pcg_min);
	#$pcg_num++ if(exists $phub{$g}{'pcg'});
	
	$tf_sum += $phub{$g}{'tf'} if(exists $phub{$g}{'tf'});
	$tf_max = $phub{$g}{'tf'} if(exists $phub{$g}{'tf'} && $phub{$g}{'tf'} > $tf_max);
	$tf_min = $phub{$g}{'tf'} if(exists $phub{$g}{'tf'} && $phub{$g}{'tf'} < $tf_min);
	
	#$tf_num++ if(exists $phub{$g}{'tf'});
	$mirna_sum += $phub{$g}{'mirna'} if(exists $phub{$g}{'mirna'});
	$mirna_max = $phub{$g}{'mirna'} if(exists $phub{$g}{'mirna'} && $phub{$g}{'mirna'} > $mirna_max);
	$mirna_min = $phub{$g}{'mirna'} if(exists $phub{$g}{'mirna'} && $phub{$g}{'mirna'} < $mirna_min);
	
	#$mirna_num++ if(exists $phub{$g}{'mirna'});
	$go_sum += $phub{$g}{'go'} if(exists $phub{$g}{'go'});
	$go_max = $phub{$g}{'go'} if(exists $phub{$g}{'go'} && $phub{$g}{'go'} > $go_max);
	$go_min = $phub{$g}{'go'}  if(exists $phub{$g}{'go'} && $phub{$g}{'go'} < $go_min); 
	#$go_num ++ if(exists $phub{$g}{'go'});
}

#print STDERR "$lncrna_sum\t$pcg_sum\t$tf_sum\t$mirna_sum\t$go_sum\n";
#print STDERR scalar(keys %node)."\n";
#print STDERR "$lncrna_num\t$pcg_num\t$tf_num\t$mirna_num\t$go_num\n";
#print STDERR Dumper(\%phub);

#$tf_num = 1 if($tf_num == 0);
my $node_num = scalar(keys %node);
my $lncrna_mean = $lncrna_sum/$node_num;
my $pcg_mean = $pcg_sum/$node_num;
my $tf_mean = $tf_sum/$node_num;
my $mirna_mean = $mirna_sum/$node_num;
my $go_mean = $go_sum/$node_num;
#$tf_mean = 1 if($tf_mean == 0);

print STDERR "$lncrna_mean\t$pcg_mean\t$tf_mean\t$mirna_mean\t$go_mean\n";
print STDERR "$lncrna_max\t$pcg_max\t$tf_max\t$mirna_max\t$go_max\n";
print STDERR "$lncrna_min\t$pcg_min\t$tf_min\t$mirna_min\t$go_min\n";

# calculate informative score
# predefine weight value
my $lncrna_w = 0;
my $pcg_w = 0.25;
my $tf_w = 0.5;
my $mirna_w = 0.25;
my $go_w = 1;

my %iscore;
foreach my $g (sort keys %phub){
	$phub{$g}{'lncrna'} = 0 unless(exists $phub{$g}{'lncrna'});
	$phub{$g}{'pcg'} = 0 unless(exists $phub{$g}{'pcg'});
	$phub{$g}{'tf'} = 0 unless(exists $phub{$g}{'tf'});
	$phub{$g}{'mirna'} = 0 unless(exists $phub{$g}{'mirna'});
	$phub{$g}{'go'} = 0 unless(exists $phub{$g}{'go'});
	
	my $tfscore = $tf_w*(($phub{$g}{'tf'}-$tf_min)/($tf_max - $tf_min));
	$tfscore = 0 if($phub{$g}{'tf'} == 0);
	my $pcgscore = $pcg_w*(($phub{$g}{'pcg'}-$pcg_min)/($pcg_max - $pcg_min));
	$pcgscore = 0 if($phub{$g}{'pcg'} == 0);
	my $mirscore = $mirna_w*(($phub{$g}{'mirna'}-$mirna_min)/($mirna_max-$mirna_min));
	$mirscore = 0 if($phub{$g}{'mirna'} == 0);
	
	$iscore{$g} = $tfscore + $pcgscore + $mirscore;
	
	#$iscore{$g} = $tf_w*(($phub{$g}{'tf'}-$tf_min)/($tf_max - $tf_min)) + $pcg_w*(($phub{$g}{'pcg'}-$pcg_min)/($pcg_max - $pcg_min)) + $mirna_w*(($phub{$g}{'mirna'}-$mirna_min)/($mirna_max-$mirna_min));
	#$iscore{$g} = $tf_w*($phub{$g}{'tf'}) + $pcg_w*($phub{$g}{'pcg'}) + $mirna_w*($phub{$g}{'mirna'});
	#$iscore{$g} = $tf_w*($phub{$g}{'tf'}/$tf_mean) + $pcg_w*($phub{$g}{'pcg'}/$pcg_mean) + $mirna_w*($phub{$g}{'mirna'}/$mirna_mean) + $go_w*($phub{$g}{'go'}/$go_mean);
	$iscore{$g} = sprintf "%.3f",$iscore{$g};
	#print "$mgi2ensembl{$g}\t$g\t$iscore{$g}\n" if($mgiType{$g} eq $HubType);
}

open IN,"$func_lncrna_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my $n = $t[0];

#foreach my $n (keys %node){
#	next unless($mgiType{$n} eq $HubType);
	
	my $neigbor_count = scalar(@{$node{$n}});
	# id id isoce
	print "$n\t$iscore{$n}\t";
	# neigbor_count tf_count mirna_count pcg_count lncRNA_count
	print "$neigbor_count\t$phub{$n}{'tf'}\t$phub{$n}{'mirna'}\t$phub{$n}{'pcg'}\t$phub{$n}{'lncrna'}\t";
	
	my $neighbor_assignedGO_count = 0;
	my %neighbor_assignedGO;
	my %assigned_GO;
	foreach my $g (@{$node{$n}}){
		if(exists $gene2go{$g} && $gene2go{$g} ne "NA"){
			$neighbor_assignedGO_count++;
			$neighbor_assignedGO{$g} = 1;
			foreach my $GOterm (@{$gene2go{$g}}){
				$assigned_GO{$GOterm} = 1;
			}
		}
	}
	my $neighbor_assignedGO_str = join ",",keys %neighbor_assignedGO;
	my $assigned_GO_str = join ",",keys %assigned_GO;
	my $assigned_GO_num = scalar(keys %assigned_GO);
	
	# functional_neighbor all_neigbor all_neigbor_gene_str GOID
	print "$neighbor_assignedGO_count\t$assigned_GO_num\t$neighbor_assignedGO_str\t$assigned_GO_str\n";
}
close IN;

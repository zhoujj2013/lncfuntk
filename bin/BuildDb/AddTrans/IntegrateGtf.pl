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

        Combine novo lncRNA to reference database.
        Author: zhoujj2013\@gmail.com
        Usage: $0 refgtf_f refbed_f refanno targetgtf_f <strand, yes/no>

USAGE
print "$usage";
exit(1);
};

my ($refgtf_f, $refbed_f, $refanno, $targetgtf_f, $strand) = @ARGV;

# convert target gtf to bed loci
my $tar_bname = basename($targetgtf_f, ".gtf");
`perl $Bin/gtfToLociBed.pl $targetgtf_f > ./$tar_bname.bed`;

# find overlaping gene
if($strand eq "yes"){
	`bedtools intersect -s -a ./$tar_bname.bed -b $refbed_f -f 0.2 -wo > ./$tar_bname.vs.ref.intersect`;
}elsif($strand eq "no"){
	`bedtools intersect -a ./$tar_bname.bed -b $refbed_f -f 0.2 -wo > ./$tar_bname.vs.ref.intersect`;
}

# read anno
my %anno;
open IN,"$refanno" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$anno{$t[0]} = $t[1];
}
close IN;

# deal with intersect
my %inter;
open IN,"./$tar_bname.vs.ref.intersect" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	push @{$inter{$t[3]}},\@t; 
}
close IN;

# get related lncRNA
my %noaddgtf;
my %relation;
my %exclude_list;

foreach my $k (keys %inter){
	my @l = sort {$a->[-1] <=> $b->[-1]} @{$inter{$k}};
	my $flag = 0;
	my @relatedGenes;
	foreach my $r (@l){
		push @relatedGenes,$r->[9];
		if($anno{$r->[9]} eq "protein coding gene"){
			$flag = 1;
		}
	}
	if($flag == 1){
		$noaddgtf{$k} = join ",",@relatedGenes;
	}elsif($flag == 0){
		$relation{$k} = $l[0][9];
	}
	$exclude_list{$k} = 1;
}

#print Dumper(\%noaddgtf);
#print Dumper(\%relation);

my %addlist;
open OUT,">","./TargetNeedAdd.gtf" || die $!;
open IN,"$targetgtf_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	# correct the gtf file format, specially for sunkun's iseerna and sebnif
	unless($t[8] =~ /gene_id "/){
		my $gid = $1 if($t[8] =~ /gene_id ([^;]+);/);
		$t[8] =~ s/gene_id ([^;]+);/gene_id "$gid";/g;
	}	
	unless($t[8] =~ /transcript_id "/){
		my $gid = $1 if($t[8] =~ /transcript_id ([^;]+);/);
		$t[8] =~ s/transcript_id ([^;]+);/transcript_id "$gid";/g;
	}
	
	my $id = $1 if($t[8] =~ /gene_id "([^"]+)";/);
	my $tid = $1 if($t[8] =~ /transcript_id "([^"]+)";/);
	
	unless(exists $exclude_list{$id}){
		$addlist{$id}{$tid} = 1;
		print OUT join "\t",@t;
		print OUT "\n";
	}
}
close IN;
close OUT;

my $ref_bname = basename($refgtf_f, ".gtf");

`cat $refgtf_f ./TargetNeedAdd.gtf > $ref_bname.gtf`;

# the final geneset
open OUT,">","TargetNeedAdd.relation.txt" || die $!;
foreach my $k (keys %addlist){
	print OUT "$k\t$k\n";
}
foreach my $k (keys %relation){
	print OUT "$k\t$relation{$k}\n";
}
close OUT;

# delete set
print STDERR "# these ncRNAs were eliminated.\n";
foreach my $k (keys %noaddgtf){
	print STDERR "$k\t$noaddgtf{$k}\n";
}

# update annotation file
open OUT,">","./TargetNeedAdd.anno" || die $!;
foreach my $k (keys %addlist){
	my @kk = keys %{$addlist{$k}};
	print OUT "$k\tlncRNA\t";
	print OUT join ",",@kk;
	print OUT "\n";
}
close OUT;

my $anno_bname = basename($refgtf_f, ".gtf");
`cat $refanno ./TargetNeedAdd.anno > ./$anno_bname.anno`;

# update bed file
`perl $Bin/gtfToLociBed.pl ./TargetNeedAdd.gtf > TargetNeedAdd.bed`;
`cat $refbed_f ./TargetNeedAdd.bed > ./$anno_bname.bed`;

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

        Create miRNA database.
        Author: zhoujj2013\@gmail.com
        Last modified: Thu Apr 13 17:07:09 HKT 2017
        Usage: $0 spe
        Species: mm9/mm10/hg19/hg38

USAGE
print "$usage";
exit(1);
};

my $spe=shift;

my $cwd = `pwd`;
chomp($cwd);

# download mature.fa.gz
print STDERR "ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz\n";
`wget -o ./wget.tmp ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz`;
while(!(-f "mature.fa.gz")){
	print STDERR "redownload: ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz\n";
	`wget -o ./wget.tmp ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz`;
}
print STDERR "gunzip...\n";
`gunzip mature.fa.gz`;

# download ftp://mirbase.org/pub/mirbase/CURRENT/aliases.txt.gz
print STDERR "ftp://mirbase.org/pub/mirbase/CURRENT/aliases.txt.gz\n";
`wget -o ./wget.tmp ftp://mirbase.org/pub/mirbase/CURRENT/aliases.txt.gz`;
while(!(-f "aliases.txt.gz")){
	print STDERR "ftp://mirbase.org/pub/mirbase/CURRENT/aliases.txt.gz\n";
	`wget -o ./wget.tmp ftp://mirbase.org/pub/mirbase/CURRENT/aliases.txt.gz`;
}
print STDERR "gunzip...\n";
`gunzip aliases.txt.gz`;

print STDERR "download microRNA records from mirBase\n";
if($spe eq "hg19" || $spe eq "hg38"){
	while(!(-f "hsa.gff3")){
		`wget -o ./wget.tmp ftp://mirbase.org/pub/mirbase/CURRENT/genomes/hsa.gff3`;
	}
	`perl $Bin/extract_miRNAs.pl mature.fa hsa > mature.miRNA.fa`;
	`perl $Bin/mirbase_gff2_pre_mat.pl hsa.gff3 aliases.txt > mirna.aliases.txt`;
}elsif($spe eq "mm9" || $spe eq "mm10"){	
	while(!(-f "mmu.gff3")){
		`wget -o ./wget.tmp ftp://mirbase.org/pub/mirbase/CURRENT/genomes/mmu.gff3`;
	}
	`perl $Bin/extract_miRNAs.pl mature.fa mmu > mature.miRNA.fa`;
	`perl $Bin/mirbase_gff2_pre_mat.pl mmu.gff3 aliases.txt > mirna.aliases.txt`;
}

print STDERR "prepare microRNA dataset.\n";
my %config;
open IN,"$cwd/../../$spe.config.txt" || die $!;
$/ = ">"; <IN>; $/ = "\n";
while(<IN>){
	my $id = $1 if(/(\S+)/);
	$/ = ">";
	my $con = <IN>;
	chomp($con);
	$/ = "\n";
	my @con = split /\n/,$con;
	foreach my $c (@con){
		my @c = split /=/,$c;
		next unless($c =~ /gbff/);
		my $name = basename($c[1], '.gz');
		$name = "../$name";
		push @{$config{$id}},$name if($c[0] =~ /gbff/);
	}
}
close IN;

open OUT,">","refseq.miRNA.lst" || die $!;
foreach my $gbff (@{$config{$spe}}){
	open IN,"$gbff" || die $!;
	$/ = "//";
	while(<IN>){
		chomp;
		my @lines = split /\n/;
		my $id;
		my $flag = 0;
		my $geneid;
		my $mibase_id;
		foreach my $l (@lines){
			$id = $1 if($l =~ /^LOCUS\s+(\S+)\s+/);
			#LOCUS       NR_039650                 86 bp    RNA     linear   PRI 19-JUN-2014
			if($flag == 1 && $l =~ /\//){
				#print $l,"\n";
				#/gene="MIR4448"
				$geneid = $1 if($l =~ /\/gene="([^"]+)"/);
				#/db_xref="miRBase:MI0016791"
				if($l =~ /\/db_xref="miRBase:([^"]+)"/){
					$mibase_id = $1;
					print OUT "$id\t$geneid\t$mibase_id\n";
				}
			}elsif($l =~ /^     gene/){
				$flag = 1;
			}else{
				$flag = 0;
			}
		}
		#print $id,"\t$geneid\t$flag\n";
	}
	close IN;
	$/ = "\n";
}
close OUT;

`perl $Bin/combine.miRbase.refseq.pl ./refseq.miRNA.lst ./mirna.aliases.txt > mirna.aliases.refseq.txt`;

#if($spe eq "hg19" || $spe eq "hg38"){
#	`perl $Bin/combine.miRbase.refseq.pl ./refseq.miRNA.lst ./human.mirna.aliases.txt > human.mirna.aliases.refseq.txt`;
#}elsif($spe eq "mm9" || $spe eq "mm10"){
#	`perl $Bin/combine.miRbase.refseq.pl ./refseq.miRNA.lst ./mouse.mirna.aliases.txt > mouse.mirna.aliases.refseq.txt`;
#}

# remove annotation files
print STDERR "remove temporary files.\n";
foreach my $gbff (@{$config{$spe}}){
	`rm $gbff`;
}
`rm ./wget.tmp`;


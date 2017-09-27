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

        This script create config.txt for build db.
        Author: zhoujj2013\@gmail.com 
        Usage: $0 config.txt

USAGE
print "$usage";
exit(1);
};

my $cfg = shift;

my @spe = ('hg38','hg19','mm9','mm10');

open OUT,">","$cfg" || die $!;

my $datestring = gmtime();
print OUT "#############\n";
print OUT "# Config file created at: $datestring\n";
print OUT "#############\n";

foreach my $s (@spe){
	print OUT ">$s\n";
	print OUT "obo=http://www.geneontology.org/ontology/gene_ontology.obo\n";
	# goa
	if($s eq "mm9" || $s eq "mm10"){
		print OUT "goa=ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE/goa_mouse.gaf.gz\n";
	}elsif($s eq "hg19" || $s eq "hg38"){
		print OUT "goa=ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/HUMAN/goa_human.gaf.gz\n";
	}
	# refgene
	if($s eq "mm9"){
		print OUT "refgene=http://hgdownload.soe.ucsc.edu/goldenPath/mm9/database/refGene.txt.gz\n";
	}elsif($s eq "mm10"){
		print OUT "refgene=http://hgdownload.soe.ucsc.edu/goldenPath/mm10/database/refGene.txt.gz\n";
	}elsif($s eq "hg19"){
		print OUT "refgene=http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz\n";
	}elsif($s eq "hg38"){
		print OUT "refgene=http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/refGene.txt.gz\n";
	}
	# gbff, for refseq annotation
	if($s eq "mm9" || $s eq "mm10"){
		`wget -o mm.gbff.log -O mm.gbff.index --retry-connrefused --waitretry=5 --read-timeout=20 --timeout=15 -t 5 ftp://ftp.ncbi.nlm.nih.gov/refseq/M_musculus/mRNA_Prot/`;
		sleep(2);
		my $i = 1;
		open IN,"./mm.gbff.index" || die $!;
		while(<IN>){
			chomp;
			if(/href=/){
				my $address = $1 if(/href="([^"]+)">/);
				if($address =~ /gbff\.gz$/){
					print OUT "gbff$i=$address\n";
					$i++;
				}
			}
		}
		close IN;
		sleep(15);
		`rm mm.gbff.log mm.gbff.index`;
	}elsif($s eq "hg19" || $s eq "hg38"){
		`wget -o hs.gbff.log -O hs.gbff.index --retry-connrefused --waitretry=5 --read-timeout=20 --timeout=15 -t 5 ftp://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/mRNA_Prot/`;
		sleep(2);
		my $i = 1;
		open IN,"./hs.gbff.index" || die $!;
		while(<IN>){
			chomp;
			if(/href=/){
				my $address = $1 if(/href="([^"]+)">/);
				if($address =~ /gbff\.gz$/){
					print OUT "gbff$i=$address\n";
					$i++;
				}
			}
		}
		close IN;
		sleep(15);
		`rm hs.gbff.log hs.gbff.index`;
	}
}
close OUT;

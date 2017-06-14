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

        Interagte novel lncRNA with reference database for LncFunNet analysis.
        Author: zhoujj2013\@gmail.com 
        Usage: $0 spe reference_db_dir novel_lncrna.gtf new_db_name outdir

USAGE
print "$usage";
exit(1);
};

my $spe = shift;
my $ref_db = shift;
my $gtf_f = shift;
my $db_name = shift;
my $outdir = shift;

if(-d "$outdir/$db_name"){
	die "ERROR: $db_name exists. Please enter a new db name or remove the existing database $outdir/$db_name.\n";
}

my $current_dir = `pwd`;
chomp($current_dir);
mkdir "$outdir/$db_name";
chdir "$outdir/$db_name";

`ln -s $ref_db/gene_ontology.obo`;
`ln -s $ref_db/goa.gaf`;
`ln -s $ref_db/GO.level12.go`;
`ln -s $ref_db/GO.network.pickle`;
`ln -s $ref_db/miRNAdb`;
`ln -s $ref_db/genome.fa`;

`perl $Bin/AddTrans/IntegrateGtf.pl $ref_db/refGene.gtf $ref_db/refGene.bed $ref_db/refGene.anno $gtf_f yes > log 2>err`;

`perl $Bin/GetElement/get_element.pl $ref_db/refGene.txt ./refGene.gtf  ./refGene.anno ./`;

chdir "$current_dir";

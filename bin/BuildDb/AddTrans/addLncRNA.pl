#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;

&usage if @ARGV<1;

sub usage {
        my $usage = << "USAGE";

        Add novo lncRNA information to PlncFunNet database.
        Author: zhoujj2013\@gmail.com
        Usage: $0 spe novo.gtf
        Note: must run in an empty diretory.
        you should standarized you novo lncRNA gtf file by StandarizedGtf.pl.

USAGE
print "$usage";
exit(1);
};

my $spe = shift;
my $novo_f = shift;

my $dbdir = "$Bin/../../../data/$spe";
# copy the common files to current fold
`cp $dbdir/gene_association.mgi .`;
`cp $dbdir/gene_ontology.obo .`;
`cp -r $dbdir/miRNAdb .`;
`cp $dbdir/$spe.level12.go .`;
`cp $dbdir/$spe.network.pickle .`;
`cp $dbdir/cds.bed .`;
`cp $dbdir/utr3.bed .`;
`cp $dbdir/utr5.bed .`;

#cds.bed               intron.bed      mm9.network.pickle  mouse.3.rna.gbff  refGene.anno.raw.log  trans.index
#exon.bed              miRNAdb         mm9.rna.gbff        refGene.anno      refGene.bed           utr3.bed
#gene_association.mgi  mm9.level12.go  mouse.1.rna.gbff    refGene.anno.log  refGene.gtf           utr5.bed
#gene_ontology.obo     mm9.log         mouse.2.rna.gbff    refGene.anno.raw  refGene.txt

# run integration
`perl $Bin/IntegrateGtf.pl $Bin/../../data/$spe/refGene.gtf $Bin/../../data/$spe/refGene.bed $Bin/../../data/$spe/refGene.anno $novo_f no > integrateGtf.log 2>integrateGtf.err`;

# get element
`perl $Bin/../GetElement/get_element_for_addlncRNA.pl $dbdir/refGene.gtf  $dbdir/refGene.anno ./`;


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

        Construct miRNA-gene regulatory network by Ago-CLIP enrich peaks.
        Author: zhoujj2013\@gmail.com, Wed Apr 12 16:31:39 HKT 2017

        Usage: perl $0 clipEnriched.bed expr_mirna_table db_dir prefix
        Example: perl $0 ago2.binding.site.bed expr_mirna.lst /data/mm9/ mESCs
        
        expr_mirna_table format:
        Mir133b
        Mir126
        Mir19
        ...
        Mir1a
        
        CLIP-seq peak calling methods:
         PARalyzer: Definition of RNA binding sites from PAR-CLIP short-read sequence data
         wavClusteR: Infer RNA binding sites from PAR-CLIP data
         CIMS: Crosslinking induced mutation site (CIMS) analysis
         Piranha: CLIP- and RIP-Seq peak caller
         CLIPper: A tool to detect CLIP-seq peaks

USAGE
print "$usage";
exit(1);
};

my ($ago2_bed_f, $expr_mir_f, $db, $prefix) = @ARGV;

`perl $Bin/getExprMirFaLst.pl $db/miRNAdb/mirna.aliases.refseq.txt $db/miRNAdb/mature.miRNA.fa $expr_mir_f`;
`$Bin/../BEDTools/bin/bedtools intersect -a $ago2_bed_f -b $db/exon.bed -u > $prefix.clip.exon.bed`;
`perl $Bin/FindMirTarget.pl ./$prefix.clip.exon.bed ./expr_mirna.fa $db`;
`perl $Bin/ConvertToGeneLevel.pl $db ./expr_mirna.lst $db/miRNAdb/mirna.aliases.refseq.txt ./MirTargetTransLevel.txt  > ./$prefix.MirTargetGeneLevel.txt 2>FindMirTarget.err`;
`perl $Bin/GetStat.pl ./MirTargetTransLevel.txt ./$prefix.MirTargetGeneLevel.txt $db/trans.index > ./$prefix.report.stat.txt`;

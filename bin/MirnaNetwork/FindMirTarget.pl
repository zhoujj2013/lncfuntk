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

        This script is designed to find MicroRNA target in some region (3'UTR, CDS or other specify region).
        input: region(bed file)  mature microRNA(microRNA.fa)
        output: microRNA target transcript/gene
		
        Author: zhoujj2013\@gmail.com
        Usage: $0 <input.bed> <microRNA.fa> <db_dir_name>
        Example:perl $0 input.bed microRNA.fa db_dir

USAGE
print "$usage";
exit(1);
};


my ($bed_f, $mir_f, $db_dir) = @ARGV;

my $bedtools = "$Bin/../BEDTools/bin/bedtools";
my $ref_genome = "$db_dir/genome.fa";
my $miranda = "$Bin/miRanda/bin/miranda";

# extract sequence from genome
my $bn = basename($bed_f, ".bed");
`$bedtools getfasta -fi $ref_genome -bed $bed_f -name -fo ./$bn.fa`;

# create the minus fasta
`perl $Bin/reverse_complement.pl ./$bn.fa > ./$bn.minus.fa`;

# run miranda to predict microRNA binding site
`$miranda $mir_f ./$bn.fa > ./$bn.miranda.output`;

`$miranda $mir_f ./$bn.minus.fa > ./$bn.minus.miranda.output`;

# deal with the miranda output
`egrep \"^>\\b\" ./$bn.miranda.output \| sed \"s\/>\/\/g\" > ./$bn.miranda.result`;

`egrep \"^>\\b\" ./$bn.minus.miranda.output \| sed \"s\/>\/\/g\" > ./$bn.minus.miranda.result`;

# restore coordinate
`perl $Bin/RestoreMirandaCoordinateToBed.pl ./$bn.miranda.result $bed_f plus > ./$bn.miranda.result.bed`;

`perl $Bin/RestoreMirandaCoordinateToBed.pl ./$bn.minus.miranda.result $bed_f minus > ./$bn.minus.miranda.result.bed`;

# combine tow strand miranda result
`cat ./$bn.minus.miranda.result.bed ./$bn.miranda.result.bed > ./$bn.Combine.miranda.result.bed`;

# intersect with 3UTR, cds, lncRNA
`$bedtools intersect -a ./$bn.Combine.miranda.result.bed -b $db_dir/exon.bed -s -wao > ./Miranda.exon.intersect`;

#`$bedtools intersect -a ./$bn.Combine.miranda.result.bed -b $db_dir/cds.bed -s -wao > ./MirandaVsCds.intersect`;

#`$bedtools intersect -a ./$bn.Combine.miranda.result.bed -b $db_dir/utr3.bed -s -wao > ./MirandaVsUtr3.intersect`;

# Extract Mir Target
#`cat MirandaVsCds.intersect MirandaVsLncRNA.intersect MirandaVsUtr3.intersect \| perl $Bin/ExtractMirTarget.pl - > MirTargetTransLevel.txt`;
`perl $Bin/ExtractMirTarget.pl $db_dir/trans.index ./Miranda.exon.intersect > MirTargetTransLevel.txt`;

# Convert to gene level, this maybe failed
#my $Mir_dir = dirname($mir_f);
#my $Mir_bn = basename($mir_f, ".fa");
#my $mgi = "/x400ifs-accel/zhoujj/data/miRbase/mmu.gff3_aliases_MGI.txt";

#`perl $Bin/ConvertToGeneLevel.pl  $db_dir $Mir_dir/$Mir_bn.lst $mgi ./MirTargetTransLevel.txt > ./MirTargetGeneLevel.txt`;

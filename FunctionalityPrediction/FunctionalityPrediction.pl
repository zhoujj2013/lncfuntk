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

        Predict functional lncRNAs from a gene regulatory network(with pre-trained weight value for nodes).
        Author: zhoujj2013\@gmail.com 
        Modified: Tue Apr 18 16:06:15 HKT 2017
        Usage: perl $0 XX.network.int XX.Neighbor.stat all.gene.lst pretrain_weigth_value

        XX.network.int: result from NetworkConstruction analysis;
        XX.Neighbor.stat: result from NetworkConstruction analysis.
        
        Format for XX.Neighbor.stat:
        geneid<tab>miRNA_binding_num<tab>tf<tab>pcg<tab>lncRNA<tab>node_type

        Format for all.gene.lst, from NetworkConstruction analysis.
        geneid<tab>node_type

USAGE
print "$usage";
exit(1);
};

my $net_f = shift;
my $stat_f = shift;
my $geneList = shift;
my $weigth_f = shift;

# calculate FIS for all lncRNAs
`grep -v \"^#\" $stat_f | grep "lncRNA" | cut -f 1,2,3,4 > potential_functional_lncRNA.Neighbor`;
`cut -f 2,3,4 potential_functional_lncRNA.Neighbor > potential_functional_lncRNA.Neighbor.stat`;
`python $Bin/ScaleMaxMin.py ./potential_functional_lncRNA.Neighbor.stat > potential_functional_lncRNA.Neighbor.stat.nor`;
`python $Bin/CalFIS.py potential_functional_lncRNA.Neighbor.stat.nor $weigth_f | paste potential_functional_lncRNA.Neighbor - > potential_functional_lncRNA.FIS`;

# generate 100 randomized network for FIS cutoff
#print "perl $Bin/generateRandomGraph.pl $geneList $net_f $weigth_f > ./random.log 2>random.err\n";
`perl $Bin/generateRandomGraph.pl $geneList $net_f $weigth_f > ./random.log 2>random.err`;
`cat  lncFunNet.randGraph/*.result > lncFunNet.random.txt`;
my $cutoff05 = `perl $Bin/CalFdr4FIS.pl lncFunNet.random.txt`;

open OUT,">","./FIS.cutoff.FDR.lt.05.txt" || die $!;
print OUT "With 100 random networks, we get FIS cutoff with FDR < 0.05:\n";
print OUT "$cutoff05\n";
close OUT;

# get the lncRNAs with functionality
`awk '\$5 >= $cutoff05' potential_functional_lncRNA.FIS > functional.lncrna.lst`;
`awk '\$5 < $cutoff05' potential_functional_lncRNA.FIS > nonfunctional.lncrna.lst`;


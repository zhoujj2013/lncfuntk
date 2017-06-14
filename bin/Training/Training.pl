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

        Training weight value for different node types.
        Author: zhoujj2013\@gmail.com 
        Created: Tue Apr 18 14:39:09 HKT 2017
        Usage: perl $0 network.stat postive.lst negative.lst

USAGE
print "$usage";
exit(1);
};

my ($stat_f, $pos_f, $neg_f) = @ARGV;

# create data matrix
`perl $Bin/generate_dataset.pl $pos_f $neg_f $stat_f > Pos.Neg.Neighbor.stat.txt`;
`cut -f 2 Pos.Neg.Neighbor.stat.txt > target.txt`;
`cut -f 3,4,5 Pos.Neg.Neighbor.stat.txt > data.txt`;

# normalization
`python $Bin/ScaleMaxMin.py ./data.txt > data_normalized.txt`;

# training
`python $Bin/plot_roc_crossval.py ./data_normalized.txt target.txt 5 LR > LR.result 2>/dev/null`; 


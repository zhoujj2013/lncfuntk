#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use File::Path qw(make_path);
use Data::Dumper;
use Cwd qw(abs_path);

&usage if @ARGV<5;

sub usage {
        my $usage = << "USAGE";

        Get coexpression network from time-serise expression profile.
        Author: zhoujj2013\@gmail.com  Wed Apr 12 15:59:18 HKT 2017
        Usage: $0 expresion_profile.lst rpkm_cutoff cal_corr_method<pearsonr|spearmanr> corr_cutoff prefix
	
        expresion_profile.lst format:
        sampleid<tab>expression_profile.lst

	expression_profile.lst format:
        geneid1<tab>rpkm1
	geneid2<tab>rpkm2

USAGE
print "$usage";
exit(1);
};

my ($expr_lst, $rpkm_cutoff, $cal_corr_method, $corr_cutoff, $prefix) = @ARGV;

`perl $Bin/filter_expr.pl $rpkm_cutoff $expr_lst > ./$prefix.expr.filtered`;
`python $Bin/CallCoExpressionPair.py ./$prefix.expr.filtered $prefix $cal_corr_method > ./$prefix.PearsonR.lst 2> ./$prefix.PearsonR.log`;
`perl $Bin/getCoExprInt.pl $corr_cutoff ./$prefix.PearsonR.lst > ./$prefix.CoExpr.int`;

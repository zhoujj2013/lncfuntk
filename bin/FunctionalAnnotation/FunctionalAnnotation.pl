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

        Perform GO/KEGG enrichment analysis for each lncRNA in gene regulatory network.
        Author: zhoujj2013\@gmail.com
        Last modified: Wed Apr 19 11:24:37 HKT 2017
        Usage: perl $0 <dbdir> <interaction> <nodelst> <functional_lncRNA>

USAGE
print "$usage";
exit(1);
};

my ($dbdir, $interaction, $nodelst, $func_lncrna) = @ARGV;

# prepare GO annoation
#print "python $Bin/PreGoAnnotation.py $nodelst $dbdir P\n";
`python $Bin/PreGoAnnotation.py $nodelst $dbdir P`;

# prepare information from network and GO database
#print "perl $Bin/PreGoEnrichment.pl $interaction ./GO.P.gene2go $func_lncrna > ./Functional.lncRNA.information.txt\n";
`perl $Bin/PreGoEnrichment.pl $interaction ./GO.P.gene2go $nodelst $func_lncrna > ./Functional.lncRNA.information.txt 2> ./Functional.lncRNA.information.log`;

# Go enrichment analysis
#print "python $Bin/GoEnrichment.py ./Functional.lncRNA.information.txt ./GO.P.gene2go ./GO.P.go2gene\n";
`python $Bin/GoEnrichment.py ./Functional.lncRNA.information.txt ./GO.P.gene2go ./GO.P.go2gene 2>./GoEnrichment.log`;

# combine GO enrichment and iscore result
`perl $Bin/generateResult.pl $func_lncrna ./lncFunNet.GO.enrich.txt > ./lncFunNet.GO.enrich.result.txt`;

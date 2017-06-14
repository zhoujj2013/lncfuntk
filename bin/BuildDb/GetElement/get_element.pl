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

        Get 3utr, 5utr, cds, exon, transcript_index, intron as bed files.
        Author: zhoujj2013\@gmail.com
        Usage: $0 refgene gtf anno outdir

USAGE
print "$usage";
exit(1);
};

my ($refgene, $gtf, $anno, $outdir) = @ARGV;

`perl $Bin/get_3utr.pl $refgene > $outdir/utr3.bed`;
`perl $Bin/get_5utr.pl $refgene > $outdir/utr5.bed`;
`perl $Bin/get_cds.pl $refgene > $outdir/cds.bed`;
`perl $Bin/get_exon_gtf.pl $gtf > $outdir/exon.bed`;
`perl $Bin/get_transcript_index.pl $anno >  $outdir/trans.index`;
`perl $Bin/get_intron_gtf.pl $gtf > $outdir/intron.bed`;

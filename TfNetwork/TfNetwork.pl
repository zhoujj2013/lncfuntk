#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use File::Path qw(make_path);
use Data::Dumper;
use Cwd qw(abs_path);

&usage if @ARGV<4;

sub usage {
        my $usage = << "USAGE";

        Construct tf-gene regulatory network from multile chipseq data.
        Author: zhoujj2013\@gmail.com, Wed Apr 12 16:04:38 HKT 2017
        Usage: $0 tf.lst up down dbdir
        Example: perl $0 tf.lst 10000 5000 /data/mm9	
	
        tf.lst format:
        TFgeneid<tab>tf_peak_file
        
        tf_peak_file: Peak calling result from MACS2 (https://github.com/taoliu/MACS), or other peak calling result in 6+ column bed format.

        Result: TfNetwork.int
        Format:
        geneid1<tab>geneid2<tab>interaction_type<tab>score<tab>evidence
	
USAGE
print "$usage";
exit(1);
};

my $tf_f = shift;
my $up = shift;
my $down = shift;
my $dbdir = shift;
$dbdir = abs_path($dbdir);

open OUT,">","./run.tf.target.sh" || die $!;
open IN,"$tf_f" || die $!;
while(<IN>){
	chomp;
	next if(/^#/);
	my @t = split /\t/;
	`rm -r ./$t[0]` if(-d "./$t[0]");
	`rm ./$t[0].bed` if(-d "./$t[0].bed");
	`cut -f 1-4 $t[1] > ./$t[0].bed`;
	$t[1] = abs_path("./$t[0].bed");
	print OUT "mkdir $t[0] && cd $t[0] && perl $Bin/call_tf_target.pl $t[0] $up $down $t[1] $dbdir/refGene.bed $dbdir/refGene.anno >$t[0].tf2gene.int 2> $t[0].target.log && cd -\n";
	#less TF_chipseq.lst | perl -ne 'chomp; my @t = split /\t/; print "mkdir $t[0] && cd $t[0] && perl /x400ifs-accel/zhoujj/Project/05.YY1_miRNA_lncRNA/bin/01TF_target/call_tf_target.pl $t[1] /x400ifs-accel/zhoujj/Project/11.mESCs_NW/02.TfTargetGene/db/minus10kplus5k 2 $t[0] $t[0] 2> log && cd -\n"' > find_target.sh
}
close IN;
close OUT;

`sh ./run.tf.target.sh`;
my @con;
my @target = glob("./*/*.tf2gene.int");
foreach my $tar_f (@target){
	open IN,"$tar_f" || die $!;
	while(<IN>){
		chomp;
		push @con,$_;
	}
	close IN;
}

open OUT,">","./TfNetwork.int" || die $!;
print OUT join "\n",@con;
close OUT;

open IN,"$tf_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	#`rm -r $t[0]`;
}
close IN;


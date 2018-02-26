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

        This script create makefile for LncFunNet analysis.
        Version: v1.0
        Author: zhoujj2013\@gmail.com
        Last modified: Wed Jun 14 16:06:43 HKT 2017
        Usage: $0 config.cfg
        
        NOTE: please check config.cfg format in ./demo directory.

USAGE
print "$usage";
exit(1);
};

my $conf=shift;
$conf = abs_path($conf);

my %conf;
&load_conf($conf, \%conf);

my $all='all: ';
my $mk;

my $program_dir = abs_path($Bin);

my $out = abs_path($conf{OUTDIR});

my $prefix = $conf{PREFIX};

my $spe = $conf{SPE};
my $ver = $conf{VERSION};

# Prepare db for lncfuntk analysis.
my $db = "";
if($conf{LNCRNA} eq "none"){
	$db = "$program_dir/data/$ver";
	unless(-d $db){
		die "####### Error #######\nYou should build supporting dataset for $ver before you run LncFunTK.\ncd <lncfuntk_install_dir>\nperl ./configure -db $ver\n#####################\n";
	}
}elsif(exists $conf{LNCRNA}){
	$db = "$program_dir/data/$ver";
	unless(-d $db){
		die "####### Error #######\nYou should build supporting dataset for $ver before you run LncFunTK.\ncd <lncfuntk_install_dir>\nperl ./configure -db $ver\n#####################\n";
	}
	my $gtf = abs_path($conf{LNCRNA});
	mkdir "$out/00PrepareDb" unless(-d "$out/00PrepareDb");
	chdir "$out/00PrepareDb";
	`ln -s $program_dir/data/$ver ./` unless(-l $ver);
	`rm -r ./new_db` if(-d "./new_db");
	`perl $Bin/bin/BuildDb/BuildDb.pl $ver ./ $gtf ./new_db`;
	chdir "$out";
	$db = "$out/00PrepareDb/new_db";
}

warn "DB\t$db\n";

my $mir_f = abs_path($conf{MIRLIST});

my $expr_f = abs_path($conf{EXPR});
my $expr_cutoff = $conf{EXPRCUTOFF};
my $pcc_cutoff = $conf{PCCCUTOFF};

my $chip_f = abs_path($conf{CHIP});
my $promoter = $conf{PROMOTER};
my ($up,$down) = split /,/,$promoter;

my $clip_f = abs_path($conf{CLIP});
my $ago2_extend = $conf{EXTEND};

my $c_outdir;
# print out the parameters
mkdir "$out/01CoExprNetwork" unless(-d "$out/01CoExprNetwork");
$c_outdir =  "$out/01CoExprNetwork";
$mk .= "01CoExprNetwork.finished: $expr_f\n";
$mk .= "\tcd $c_outdir && perl $Bin/bin/CoExprNetwork/CoExprNetwork.pl $expr_f $expr_cutoff pearsonr $pcc_cutoff $prefix > 01CoExprNetwork.log 2>01CoExprNetwork.err && cd - && touch 01CoExprNetwork.finished\n";
$all .= "01CoExprNetwork.finished "; 

mkdir "$out/02TfNetwork" unless(-d "$out/02TfNetwork");
$c_outdir =  "$out/02TfNetwork";
$mk .= "02TfNetwork.finished: 01CoExprNetwork.finished\n";
$mk .= "\tcd $c_outdir && perl $Bin/bin/TfNetwork/TfNetwork.pl $chip_f $up $down $db > 02TfNetwork.log 2>02TfNetwork.err && cd - && touch 02TfNetwork.finished\n";
$all .= "02TfNetwork.finished ";

mkdir "$out/03MirnaNetwork" unless(-d "$out/03MirnaNetwork");
$c_outdir =  "$out/03MirnaNetwork";
$mk .= "03MirnaNetwork.finished: 02TfNetwork.finished\n";
$mk .= "\tcd $c_outdir && perl $Bin/bin/MirnaNetwork/MirnaNetwork.pl $clip_f $mir_f $db $prefix && cd - && touch 03MirnaNetwork.finished\n";
$all .= "03MirnaNetwork.finished ";

# create config file for network construction
mkdir "$out/04NetworkConstruction" unless(-d "$out/04NetworkConstruction");
# generate config file for network construction
open OUT,">","$out/04NetworkConstruction/config.txt" || die $!;
print OUT "InferredInt=$out/01CoExprNetwork/$prefix.CoExpr.int\n";
print OUT "DirectedInt=$out/02TfNetwork/TfNetwork.int\n";
print OUT "DirectedInt=$out/03MirnaNetwork/$prefix.MirTargetGeneLevel.txt\n";
print OUT "KeyTfList=$chip_f\n";
print OUT "MirnaList=$mir_f\n";
print OUT "OtherGeneList=$out/01CoExprNetwork/$prefix.remain.lst\n";
print OUT "Prefix=$prefix\n";
print OUT "DbDir=$db\n";
close OUT;

$c_outdir =  "$out/04NetworkConstruction";
$mk .= "04NetworkConstruction.finished: 03MirnaNetwork.finished\n";
$mk .= "\tcd $c_outdir && perl $Bin/bin/NetworkConstruction/NetworkReconstruction.pl ./config.txt > ./$prefix.log 2>$prefix.err && cd - && touch 04NetworkConstruction.finished\n";
$all .= "04NetworkConstruction.finished ";

mkdir "$out/05FunctionalityPrediction" unless(-d "$out/05FunctionalityPrediction");
$c_outdir =  "$out/05FunctionalityPrediction";
$mk .= "05FunctionalityPrediction.finished: 04NetworkConstruction.finished\n";
$mk .= "\tcd $c_outdir && perl $Bin/bin/FunctionalityPrediction/FunctionalityPrediction.pl $out/04NetworkConstruction/04NetworkStat/$prefix.int.txt $out/04NetworkConstruction/04NetworkStat/$prefix.Neighbor.stat $out/04NetworkConstruction/$prefix.geneexpr.lst $Bin/bin/Training/pretrained.weight.value.lst > ./$prefix.log 2> ./$prefix.err && cd - && touch 05FunctionalityPrediction.finished\n";
$all .= "05FunctionalityPrediction.finished ";

mkdir "$out/06FunctionalAnnotation" unless(-d "$out/06FunctionalAnnotation");
$c_outdir =  "$out/06FunctionalAnnotation";
$mk .= "06FunctionalAnnotation.finished: 05FunctionalityPrediction.finished\n";
$mk .= "\tcd $c_outdir && perl $Bin/bin/FunctionalAnnotation/FunctionalAnnotation.pl $db $out/04NetworkConstruction/04NetworkStat/$prefix.int.txt $out/04NetworkConstruction/$prefix.geneexpr.lst $out/05FunctionalityPrediction/functional.lncrna.lst && cd - && touch 06FunctionalAnnotation.finished\n";
$all .= "06FunctionalAnnotation.finished ";

mkdir "$out/07Report" unless(-d "$out/07Report");
$c_outdir =  "$out/07Report";
$mk .= "07Report.finished: 06FunctionalAnnotation.finished\n";
$mk .= "\tcd $c_outdir && perl $Bin/bin/Report/Report.pl $conf && cd - && touch 07Report.finished\n";
$all .= "07Report.finished ";

#mkdir "$out/07pioritizedFuncLnc" unless(-d "$out/07pioritizedFuncLnc");
#$c_outdir = "$out/07pioritizedFuncLnc";
#$mk .= "07pioritizedFuncLnc.finished: 06calcFDRCutoff.finished\n";
#$mk .= "\tcd $c_outdir && perl $Bin/PrioritizeFunLnc/PrioritizeFunLnc.pl $Bin/../data/db/$ver $out/04NetWorkConstruct/04NetworkStat/$prefix.int.txt $out/04NetWorkConstruct/04NetworkStat/$prefix.node.degree.txt $ver $out/06calcFDRCutoff/FIScutoff.05.txt $prefix > $prefix.log 2> $prefix.err && Rscript $Bin/PrioritizeFunLnc/density.r $prefix $out/05GenerateRandomNetwork/$prefix.random.iscore:3:blue $out/07pioritizedFuncLnc/$prefix.informative.hub.raw.iscore:3:red > density.log 2>density.err && cd - && touch 07pioritizedFuncLnc.finished\n";
#$all .= "07pioritizedFuncLnc.finished ";
#
#mkdir "$out/08retriveFFLmotif" unless(-d "$out/08retriveFFLmotif");
#$c_outdir = "$out/08retriveFFLmotif";
#$mk .= "08retriveFFLmotif.finished: 07pioritizedFuncLnc.finished\n";
#$mk .= "\tcd $c_outdir && ";
#$mk .= " perl $Bin/FindCircuitry/get_mir_tf_lncrna.pl $out/04NetWorkConstruct/04NetworkStat/mESCs.node.degree.txt && ";
#$mk .= " perl $Bin/FindCircuitry/find_mir_tf_lncrna_motif.pl tf.lst,1 mir.lst,1 lncrna.lst,1 $out/04NetWorkConstruct/04NetworkStat/$prefix.int.txt > TF.mir.lncrna.FFLmotif.txt &&";
#$mk .= " cd - && touch 08retriveFFLmotif.finished\n";
#$all .= "08retriveFFLmotif.finished";

#### write you things ###
make_path abs_path($conf{OUTDIR});
open OUT, ">$out/makefile";
print OUT $all, "\n";
print OUT $mk, "\n";
close OUT;
$all = "all: ";
$mk = "";

#########################

sub load_conf
{
    my $conf_file=shift;
    my $conf_hash=shift; #hash ref
    open CONF, $conf_file || die "$!";
    while(<CONF>)
    {
        chomp;
        next unless $_ =~ /\S+/;
        next if $_ =~ /^#/;
        warn "$_\n";
        my @F = split"\t", $_;  #key->value
        $conf_hash->{$F[0]} = $F[1];
    }
    close CONF;
}

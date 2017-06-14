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

        Description of this script.
        Author: zhoujj2013\@gmail.com
        Usage: $0 <inter_f> <expr_element_f>

USAGE
print "$usage";
exit(1);
};

my ($inter_f, $expr_element_f) = @ARGV;

my %inter;
open IN,"$inter_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$inter{$t[0]}{$t[1]} = \@t;
}
close IN;

my %e;
open IN,"$expr_element_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$e{$t[0]} = $t[2];
}
close IN;

my $tf_tf = 0;
my $tf_pcg = 0;
my $tf_mirna = 0;
my $tf_lncrna = 0;

my $pcg_pcg = 0;
my $pcg_mirna = 0;
my $pcg_lncrna = 0;

my $lncrna_lncrna = 0;
my $lncrna_mirna = 0;

my $mirna_mirna = 0;


foreach my $e1 (keys %inter){
	foreach my $e2 (keys %{$inter{$e1}}){
		if($e{$e1} eq "TF" && $e{$e2} eq "TF"){
			$tf_tf++;
			next;
		}
		
		if(($e{$e1} eq "pcg" && $e{$e2} eq "TF") || ($e{$e1} eq "TF" && $e{$e2} eq "pcg") ){
			$tf_pcg++;
			next;
		}

		if( ($e{$e1} eq "TF" && $e{$e2} eq "lncRNA") || ($e{$e1} eq "lncRNA" && $e{$e2} eq "TF") ){
			$tf_lncrna++;
			next;
		}
		
		if( ($e{$e1} eq "TF" && $e{$e2} eq "miRNA") || ($e{$e1} eq "miRNA" && $e{$e2} eq "TF") ){
            $tf_mirna++;
            next;
        }
		
		if($e{$e1} eq "pcg" && $e{$e2} eq "pcg"){
			$pcg_pcg++;
			next;
		}
		
		if( ($e{$e1} eq "pcg" && $e{$e2} eq "lncRNA") || ($e{$e1} eq "lncRNA" && $e{$e2} eq "pcg")){
            $pcg_lncrna++;
            next;
        }
		
		if( ($e{$e1} eq "pcg" && $e{$e2} eq "miRNA") || ($e{$e1} eq "miRNA" && $e{$e2} eq "pcg")){
            $pcg_mirna++;
            next;
        }
		
		if($e{$e1} eq "lncRNA" && $e{$e2} eq "lncRNA"){
			$lncrna_lncrna++;
			next;
		}
		
		if( ($e{$e1} eq "lncRNA" && $e{$e2} eq "miRNA") || ($e{$e1} eq "miRNA" && $e{$e2} eq "lncRNA")){
            $lncrna_mirna++;
            next;
        }
		
		if($e{$e1} eq "miRNA" && $e{$e2} eq "miRNA"){
			$mirna_mirna++;
			next;
		}
	}
}

print "tf_tf: $tf_tf\n";
print "tf_pcg: $tf_pcg\n";
print "tf_mirna: $tf_mirna\n";
print "tf_lncrna: $tf_lncrna\n";

print "pcg_pcg: $pcg_pcg\n";
print "pcg_mirna: $pcg_mirna\n";
print "pcg_lncrna: $pcg_lncrna\n";

print "lncrna_lncrna: $lncrna_lncrna\n";
print "lncrna_mirna: $lncrna_mirna\n";

print "mirna_mirna: $mirna_mirna\n";


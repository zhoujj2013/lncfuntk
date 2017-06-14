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

        Generate functional enrichment result.
        Author: zhoujj2013\@gmail.com 
        Usage: $0 functional_lncRNA.lst XX.enrich.result.txt

USAGE
print "$usage";
exit(1);
};

my $lncRNA_f = shift;
my $enrich_f = shift;

my %enrich;
open IN,"$enrich_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$enrich{$t[0]} = \@t;
}
close IN;

open IN,"$lncRNA_f" || die $!;
while(<IN>){
        chomp;
	my @t = split /\t/;
	my @en = @{$enrich{$t[0]}};
	my $id = shift @t;
	my $score = pop(@t);
	my @con;
	push @con,$id;
	push @con,$score;
	push @con,$en[1];
	push @con,$en[2];
	push @con,$en[4];
	push @con,$en[5];
	push @con,$en[6];
	#push @con,@t;
	print join "\t",@con;
	print "\n";
}
close IN;

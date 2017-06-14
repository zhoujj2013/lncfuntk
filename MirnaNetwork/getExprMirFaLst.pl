#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;

&usage if @ARGV<1;

sub usage {
        my $usage = << "USAGE";

        Get miRNA fasta and miRNA list from index information file. 
        Author: zhoujj2013\@gmail.com
        Usage: $0 mirna.aliases.refseq.txt mature.miRNA.fa mir_official_genename 

USAGE
print "$usage";
exit(1);
};

my $aliases_f = shift;
my $mature_fa = shift;
my $mir_official_expr_f = shift;

my %fa;
open IN,"$mature_fa" || die $!;
$/ = ">"; <IN>; $/ = "\n";
while(<IN>){
	chomp;
	my $id = $1 if(/^(\S+)/);
	$/ = ">";
	my $seq = <IN>;
	chomp($seq);
	$/ = "\n";
	$fa{$id} = $seq;
}
close IN;

my %ali;
open IN,"$aliases_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$ali{$t[0]} = \@t;
}
close IN;


#print Dumper(\%fa);
#print STDERR Dumper(\%ali);

my %expr_mirna;
my %expr_mirna_mature;

open OUT,">","./expr_mirna.lst" || die $!;
open OUT1,">","./expr_mirna.fa" || die $!;
open IN,"$mir_official_expr_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if(exists $ali{$t[0]}){
		my $mature_name = $ali{$t[0]}[-1];
		my @mature_name = split /;/,$mature_name;
		foreach my $n (@mature_name){
			#print "$n\n";
			if(exists $fa{$n}){
				my $a = "$t[0]\t$n\n";
				$expr_mirna{$a} = 1;
				#print OUT "$t[0]\t$n\n";
				unless(exists $expr_mirna_mature{$n}){
					print OUT1 ">$n\n";
					print OUT1 "$fa{$n}";	
				}
				$expr_mirna_mature{$n} = 1
				#print OUT1 ">$n\n";
				#print OUT1 "$fa{$n}";
			}
		}
	}
}
close IN;

foreach my $l (keys %expr_mirna){
	print OUT "$l";
}

close OUT;
close OUT1;

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
        Author: zhoujj2013\@gmail.com 
        Usage: $0 config.cfg

USAGE
print "$usage";
exit(1);
};

my $refseq= shift;
my $aliase = shift;

my %ref;
open IN,"$refseq" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	next if(/^#/);
	if($t[-1] ne ""){
		$ref{$t[-1]} = \@t;
	}
}
close IN;

open IN,"$aliase" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if(exists $ref{$t[0]}){
		my ($refid,$sym) = ($ref{$t[0]}[0],$ref{$t[0]}[1]);
		print "$sym\t$refid\t$t[0]\t$t[1]\t$t[2];$t[3]\n";
	}
}
close IN;

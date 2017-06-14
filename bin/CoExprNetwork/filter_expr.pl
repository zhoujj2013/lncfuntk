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

        This script design for express filtering in specific column.
        Author: zhoujj2013\@gmail.com 
        Usage: $0 cutoff xx.expr

USAGE
print "$usage";
exit(1);
};

my $cutoff = shift;
my $expr_f = shift;

my @expr;
open IN,"$expr_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	push @expr,\@t;
}
close IN;

my $primary_id = $expr[0][0];
#print $primary_id,"\n";
my $primary_f = $expr[0][1];
#print $primary_f,"\n";
# initialized
#my @init;
#foreach(@expr){
#	push @init,0.01;	
#}

my %geneid;
open IN,"$primary_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if($t[1] >= $cutoff ){
		my @init;
		foreach(@expr){
        		push @init,0.01;
		}
		$geneid{$t[0]} = \@init;
        }
	
}
close IN;

my $i = 0;
my @header = ("geneid");
foreach my $fstr (@expr){
	my ($id,$f) = @$fstr;
	push @header,$id;
	open IN,"$f" || die $!;
	while(<IN>){
		chomp;
		my @t = split /\t/;
		if(exists $geneid{$t[0]} && $t[1] > 0.01){
			$geneid{$t[0]}[$i] = $t[1];
		}
	}
	close IN;
	$i++;
}

#print Dumper(\%geneid);
#print join "\t",@header;
#print "\n";
foreach my $g (keys %geneid){
	my $flag = 0;
	foreach my $s (@{$geneid{$g}}){
		if($s > 0.01){
			$flag = 1;
		}
	}
	if($flag == 1){
		print "$g\t";
		print join "\t",@{$geneid{$g}};
		print "\n";
	}
}


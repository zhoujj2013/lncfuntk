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

my ($pos_f, $neg_f, $matrix) = @ARGV;

my @mat;
my %pos;
open OUT,">","./target.txt" || die $!;
open IN,"$pos_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	print OUT "$t[0]\t1\n";
	push @mat,$t[0];
	$pos{$t[0]} = 1;
}
close IN;

my %neg;
open IN,"$neg_f" || die $!;
while(<IN>){
        chomp;
        my @t = split /\t/;
        print OUT "$t[0]\t0\n";
        push @mat,$t[0];
	$neg{$t[0]} = 1;
}
close IN;
close OUT;

my %dat;
open IN,"$matrix" || die $!;
<IN>;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my $id = shift @t;
	#$dat{$t[0]} = "$t[1]\t$t[2]\t$t[3]\t$t[4]\t$t[5]\t$t[6]";
	$dat{$id} = \@t;
}
close IN;

my @blank = (0,0,0,0,"lncRNA");
foreach my $k (@mat){
	if(exists $dat{$k} && (exists $pos{$k} || exists $neg{$k})){
		my $target;
		$target = 1 if(exists $pos{$k});
		$target = 0 if(exists $neg{$k});
		print "$k\t$target\t";
		print join "\t",@{$dat{$k}};
		print "\n";
	}else{
		my $target;
		$target = 1 if(exists $pos{$k});
		$target = 0 if(exists $neg{$k});
		print "$k\t$target\t";
		print join "\t",@blank;
		print "\n";
	}
}


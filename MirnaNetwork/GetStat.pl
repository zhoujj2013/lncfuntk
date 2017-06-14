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
        Usage: $0 <para1> <para2>
        Example:perl $0 para1 para2

USAGE
print "$usage";
exit(1);
};


my $trans = shift;
my $genes = shift;
my $anno = shift;

my %trans2type;
my %gene2type;

open IN,"$anno" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$trans2type{$t[0]} = $t[2];
	$gene2type{$t[1]} = $t[2];
}
close IN;

my %transStat;
open IN,"$trans" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if(exists $trans2type{$t[1]}){
		$transStat{$trans2type{$t[1]}}{'gene'}{$t[1]} = 1;
		$transStat{$trans2type{$t[1]}}{'stat'}++;
	}else{
		my $id = $1 if($t[1] =~ /(.*)-\d+/g);
		$transStat{$trans2type{$id}}{'gene'}{$t[1]} = 1;
		$transStat{$trans2type{$id}}{'stat'}++;
	}
}
close IN;

my %geneStat;
open IN,"$genes" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$geneStat{$gene2type{$t[1]}}{'gene'}{$t[1]} = 1;
	$geneStat{$gene2type{$t[1]}}{'stat'}++;
}
close IN;

print "trans level\n";
print "\ttrans num\n";
foreach my $k (keys %transStat){
	my $num = scalar(keys %{$transStat{$k}{'gene'}});
	print "$k\t$num\n";
}

print "\ttrans interaction\n";
foreach my $k (keys %transStat){
    my $num = $transStat{$k}{'stat'};
    print "$k\t$num\n";
}

print "\n\ngene level\n";
print "\tgene num\n";
foreach my $k (keys %geneStat){	
	my $num = scalar(keys %{$geneStat{$k}{'gene'}});
	print "$k\t$num\n";
}
print "\tgene interaction\n";
foreach my $k (keys %geneStat){
    my $num = $geneStat{$k}{'stat'};
    print "$k\t$num\n";
}


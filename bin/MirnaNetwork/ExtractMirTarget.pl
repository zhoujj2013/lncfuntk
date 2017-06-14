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

my $trans_index = shift @ARGV;

my %index;

open IN,"$trans_index" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$index{$t[1]} = $t[2];
}
close IN;

my %inter;
#open IN,"$intersect_f" || die $!;
while(<>){
	chomp;
	my @t = split /\t/;
	next unless($t[6] =~ /chr/);
	my @id1 = split /_/,$t[3];
	my $id2 = $t[9];

	my $name = $t[10];
	# only for this genetype
	if(exists $index{$name} && ($index{$name} eq "miRNA" || $index{$name} eq "rRNA" || $index{$name} eq "snoRNA" || $index{$name} eq "snRNA" || $index{$name} eq "otherRNA")){
		next;
	}
	my $id1 = $id1[0];
	$inter{$id1}{$id2} = 1;
}
close IN;

foreach my $k (keys %inter){
	foreach my $kk (keys %{$inter{$k}}){
		print "$k\t$kk\tmt\tnegative\tClipseqMiranda\n";
	}
}

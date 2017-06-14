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

my $gtf_f = shift;

my %gtf;

open IN,"$gtf_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my $geneid;
	if($t[8] =~ /gene_id "([^"]+)";/ ){
		$geneid = $1;
	}elsif($t[8] =~ /gene_id ([^;]+);/){
		$geneid = $1;
	}
	push @{$gtf{$geneid}},[$t[0],$t[3],$t[4],$t[6]];
}
close IN;

foreach my $g (keys %gtf){
	my @exon = sort {$a->[1] <=> $b->[1]} @{$gtf{$g}};
	print "$exon[0][0]\t$exon[0][1]\t$exon[-1][2]\t$g\t0\t$exon[0][3]\n";
}


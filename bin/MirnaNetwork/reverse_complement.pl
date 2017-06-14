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

my $fa = shift;

open IN,"$fa" || die $!;
$/ = ">"; <IN>; $/ = "\n";
while(<IN>){
	chomp;
	my $id = $1 if(/(\S+)/);
	$id = "$id\_rc";
	$/ = ">";
	my $seq = <IN>;
	chomp($seq);
	$/ = "\n";
	
	$seq =~ s/\n//g;
	$seq = reverse $seq;
	#print $seq;
	$seq =~ tr/ATCGatcg/TAGCtagc/;
	print ">$id\n$seq\n";
}
close IN;

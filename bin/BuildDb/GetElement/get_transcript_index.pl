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

my $anno_f = shift;

open IN,"$anno_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my @trans = split /,/,$t[-1];
	foreach my $tid (@trans){
		print "$tid\t$t[0]\t$t[1]\n";
	}
}
close IN;

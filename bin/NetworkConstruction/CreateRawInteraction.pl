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

my $gene_element_f = shift;

my %gene;

open IN,"$gene_element_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$gene{$t[0]} = $t[0];
}
close IN;

my %int;
foreach my $f (@ARGV){
	open IN,"$f" || die $!;
	while(<IN>){
		chomp;
		my @t = split /\t/;
		unless(exists $gene{$t[0]} and exists $gene{$t[1]}){
			next;
		}
		if(exists $int{$t[0]}{$t[1]}){
			$int{$t[0]}{$t[1]}{'evidence'} = "$int{$t[0]}{$t[1]}{'evidence'};$t[-1]";
		}elsif(exists $int{$t[1]}{$t[0]}){
			$int{$t[1]}{$t[0]}{'evidence'} = "$int{$t[1]}{$t[0]}{'evidence'};$t[-1]";
		}else{
			$int{$t[0]}{$t[1]}{'evidence'} = $t[-1];
			$int{$t[0]}{$t[1]}{'type'} = $t[2];
			$int{$t[0]}{$t[1]}{'score'} = $t[3];
		}
	}
	close IN;
}

#print Dumper(\%int);

foreach my $k1 (keys %int){
	foreach my $k2 (keys %{$int{$k1}}){
		my @e = split /;/,$int{$k1}{$k2}{'evidence'};
		my %e;
		foreach my $e (@e){
			$e{$e} = 1;
		}
		my $str = join ";",keys %e;
		print "$k1\t$k2\t$int{$k1}{$k2}{'type'}\t$int{$k1}{$k2}{'score'}\t$str\n";
	}
}



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


my ($gff3_f,$alias_f) = @ARGV;

my $ac;
my %h;
open IN,"$gff3_f" || die $!;
while(<IN>){
	chomp;
	next if(/^#/);
	my @t = split /\t/;
	if($t[2] =~ /miRNA_primary_transcript/){
		$ac = $1 if($t[8] =~ /Alias=([^;]+);/);	
	}
	if($t[2] eq "miRNA"){
		my $s_ac = $1 if($t[8] =~ /Alias=([^;]+);/);
		my $f_ac = $1 if($t[8] =~ /Derives_from=([^_]+)_\S*$/);
		push @{$h{$ac}},$s_ac;
	}
}
close IN;

my %al;

open IN,"$alias_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my @mat = split /;/,$t[1];
	$al{$t[0]} = \@mat;
}
close IN;

#print Dumper(\%h);

foreach my $k (keys %h){
	my @str;
	if(exists $al{$k}){
		push @str,$al{$k};
	}else{
		print STDERR "$k\n";
	}

	foreach my $e (@{$h{$k}}){
		if(exists $al{$e}){
			push @str,$al{$e};
		}else{
			print STDERR "$e\n";
		}
	}
	
	print "$k\t";
	print join ";",@{$h{$k}};
	print "\t";

	my $mir = shift @str;
	print join ";",@{$mir};
	print "\t";
	
	my @ss;
	foreach my $s (@str){
		my $ss_str = join ";",@{$s};
		push @ss,$ss_str;
	}
	print join ";",@ss;
	print "\n";
}

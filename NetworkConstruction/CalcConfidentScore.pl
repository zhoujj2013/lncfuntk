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

###########################################
my ($coexpr_raw_f, $chromatin_f, $gene_expr_f) = @ARGV;

my %chromatin;
open IN,"$chromatin_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$chromatin{$t[0]}{$t[1]} = 1;
}
close IN;

my %expr;
open IN,"$gene_expr_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$expr{$t[0]} = 1;
}
close IN;

############################################
my %int;
open IN,"$coexpr_raw_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	next unless(exists $expr{$t[0]} && exists $expr{$t[1]});
	if($expr{$t[0]} eq "miRNA" || $expr{$t[1]} eq "miRNA"){
		next;
	}
	$int{$t[0]}{$t[1]}{'con'} = \@t;
}
close IN;

foreach my $tf (keys %chromatin){
	my %tars;
	foreach my $target (keys %{$chromatin{$tf}}){
		$tars{$target} = 1;
		if(exists $int{$tf}{$target} && !(exists $int{$tf}{$target}{'out'})){
			print join "\t",@{$int{$tf}{$target}{'con'}};
			print "\n";
			$int{$tf}{$target}{'out'} = 1;
		}elsif(exists $int{$target}{$tf}){
			print join "\t",@{$int{$target}{$tf}{'con'}};
			print "\n";
			$int{$target}{$tf}{'out'} = 1;
		}
	}
	foreach my $k (keys %tars){
		if(exists $int{$k}){
			foreach my $kk (keys %{$int{$k}}){
				if(exists $tars{$kk} && !(exists $int{$k}{$kk}{'out'})){
					print join "\t",@{$int{$k}{$kk}{'con'}};
					print "\n";
					$int{$k}{$kk}{'out'} = 1;
				}
			}
		}
	}
}

#############################################
#open IN,"$coexpr_raw_f" || die $!;
#while(<IN>){
#	chomp;
#	my @t = split /\t/;
#	next unless(exists $expr{$t[0]} && exists $expr{$t[1]});
#	my $flag = 0;
#	if(exists $chromatin{$t[0]}{$t[1]} || exists $chromatin{$t[1]}{$t[0]}){
#		$flag = 1;
#	}else{
#		foreach my $id (keys %chromatin){
#			my $tar = $chromatin{$id};
#			if(exists $tar->{$t[0]} && exists $tar->{$t[1]}){
#				$flag = 1;
#				last;
#			}
#		}
#	}
#	
#	#output
#	if($flag == 1){
#		print join "\t",@t;
#		print "\n";
#	}
#}
#close IN;


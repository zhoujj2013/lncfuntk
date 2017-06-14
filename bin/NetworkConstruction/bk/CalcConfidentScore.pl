#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;
use lib "/home/zhoujj/my_lib/pm";
use bioinfo;

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

my ($all_int_f, $directed_int_f, $inferred_int_f, $ra_scored_inferred_int_f) = @ARGV;

my %directed;
open IN,"$directed_int_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	unless(exists $directed{$t[0]}{$t[1]} || exists $directed{$t[1]}{$t[0]}){
		my $score = 1;
		if($t[3] =~ /\d+$/){
			$score = $t[3];
		}else{
			$score = 1;
		}
		$directed{$t[0]}{$t[1]} = $score;
	}
}
close IN;

my %inferred;
open IN,"$inferred_int_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	unless(exists $inferred{$t[0]}{$t[1]} || exists $inferred{$t[1]}{$t[0]}){
		my $score = 0;
		if($t[3] =~ /\d+$/){
			$score = $t[3];
		}else{
			$score = 1;
		}
		$inferred{$t[0]}{$t[1]} = $score;
	}
}
close IN;

my %ra;
open IN,"$ra_scored_inferred_int_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	unless(exists $ra{$t[0]}{$t[1]} || exists $ra{$t[1]}{$t[0]}){
		$ra{$t[0]}{$t[1]} = $t[3];
	}
}
close IN;

my %int;
open IN,"$all_int_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if(exists $directed{$t[0]}{$t[1]} || exists $directed{$t[1]}{$t[0]}){
		my $score = abs($directed{$t[0]}{$t[1]});
		$t[3] = $score;
	}elsif(exists $inferred{$t[0]}{$t[1]} || exists $inferred{$t[1]}{$t[0]}){
		my $score1 = 0;
		if(exists $inferred{$t[0]}{$t[1]}){
			$score1 = $inferred{$t[0]}{$t[1]};
		}elsif(exists $inferred{$t[1]}{$t[0]}){
			$score1 = $inferred{$t[1]}{$t[0]};
		}
		my $score2 = 0;
		if(exists $ra{$t[0]}{$t[1]}){
			$score2 = abs($ra{$t[0]}{$t[1]});
		}elsif(exists $ra{$t[1]}{$t[0]}){
			$score2 = abs($ra{$t[1]}{$t[0]});
		}
		
		my $score = ($score1 + $score2)/2;
		$t[3] = $score;
	}
	print join "\t",@t;
	print "\n";
}
close IN;

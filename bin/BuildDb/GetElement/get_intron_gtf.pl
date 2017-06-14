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

        Get intron interval from gtf file.
        Author: zhoujj2013\@gmail.com
        Usage: $0 XX.gtf

USAGE
print "$usage";
exit(1);
};

my $gtf_f = shift;

my %gtf;
my @gtf;

open IN,"$gtf_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;

	my $id = $1 if($t[8] =~ /transcript_id "([^"]+)";/);
	my $name = $1 if($t[8] =~ /gene_id "([^"]+)";/);
	
	#$id =~ s/(-\d+)//g;
	# turn to half-open 0 base coordinate
	($t[3], $t[4]) = ($t[4], $t[3]) if($t[3] > $t[4]);
	
	push @{$gtf{$id}},\@t;
	#print "$t[0]\t$t[3]\t$t[4]\t$id\t$name\t$t[6]\n";
}
close IN;

foreach my $id (keys %gtf){
	my @t = sort {$a->[3] <=> $b->[3]} @{$gtf{$id}};
	push @gtf,@t;
}


# output intron
my $preid = "";
my $start = "";

foreach my $l (@gtf){
	my @t = @$l;
	
	my $id = $1 if($t[8] =~ /transcript_id "([^"]+)";/);
	my $name = $1 if($t[8] =~ /gene_id "([^"]+)";/);
	
	($t[3],$t[4]) = ($t[4],$t[3]) if($t[3] > $t[4]);
	
	if($preid ne $id){
		$start = $t[4];
		$preid = $id;
	}elsif($preid eq $id){
		my $s = $start;
		my $e = $t[3]-1;
		$start = $t[4];
		
		#$id =~ s/(-\d+)//g;
		print "$t[0]\t$s\t$e\t$id\t$name\t$t[6]\n";
	}
}

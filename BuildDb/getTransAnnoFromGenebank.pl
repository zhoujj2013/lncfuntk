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


my $gb_f = shift;

open IN,"$gb_f" || die $!;
$/ = "\/\/\n";
while(<IN>){
	my $r = $_;
	chomp($r);
	next if(length($r) == 0);
	my $tranid = $1 if( $r =~ /LOCUS\s+(\S+)/);
	my $desc = $1 if($r =~ /DEFINITION\s+(.*)ACCESSION/s);
	$desc =~ s/\n/ /g;
	$desc =~ s/\s+/ /g;
	
	unless(defined $tranid || $tranid eq ""){
		print STDERR $r,"\n";
	}
	#print "$tranid\n";
	if($tranid =~ /^NM/){
		print "$tranid\tprotein coding gene\t$desc\n";
	}elsif($tranid =~ /^NR/){
		if($r =~ /\/ncRNA_class="([^"]+)"/g){
			my $ncrna_class = $1;
			print "$tranid\t$ncrna_class\t$desc\n";
		}elsif($r =~ /\s+(rRNA)\b/){
			my $ncrna_class = $1;
			print "$tranid\t$ncrna_class\t$desc\n";
		}elsif($r =~ /\/pseudo/){
			my $ncrna_class = "pseudogene";
			print "$tranid\t$ncrna_class\t$desc\n";
		}else{
			my $ncrna_class = "unclassified non-coding RNA gene";
			print "$tranid\t$ncrna_class\t$desc\n";
			#print STDERR "$r\n";
		}
	}
}
close IN;
$/ = "\n";

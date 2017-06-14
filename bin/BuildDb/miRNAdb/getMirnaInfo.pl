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
	if($tranid =~ /^NR/){
		if($r =~ /\/ncRNA_class="([^"]+)"/g){
			my $ncrna_class = $1;
			my $geneid;
			my $mibaseid;
			if($ncrna_class eq "miRNA"){
				if($r =~ /\/gene="([^"]+)"/g){
					$geneid = $1;
				}
				if($r =~ /\/db_xref="miRBase:(MI\d+)"/){
					$mibaseid = $1;
				}	
				print "$tranid\t$ncrna_class\t$geneid\t$mibaseid\n";
			}
		}
	}
}
close IN;
$/ = "\n";

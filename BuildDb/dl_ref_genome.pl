#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use File::Path qw(make_path);
use Data::Dumper;
use Cwd qw(abs_path);

&usage if @ARGV<1;

sub usage {
        my $usage = << "USAGE";

        Author: zhoujj2013\@gmail.com 
        Usage: $0 mm9
        Only support mm9/mm10/hg19/hg38

USAGE
print "$usage";
exit(1);
};

my $spe=shift;

print STDERR "Get chromosome list.\n";
`wget -o $spe.log -O $spe.index http://hgdownload.cse.ucsc.edu/goldenPath/$spe/chromosomes/`;
sleep(2);

my @name;
open IN,"./$spe.index" || die $!;
while(<IN>){
        chomp;
        if(/href=/){
                my $address = $1 if(/href="([^"]+)">/);
		next unless($address =~ /^chr/);
                unless($address =~ /(chrUn|random\.fa|_hap|_alt\.fa)/){
			print STDERR "$address\n";
			`rsync -avzP rsync://hgdownload.cse.ucsc.edu/goldenPath/$spe/chromosomes/$address .`;
			
			while(!(-f $address)){
				print STDERR "redownload: $address\n";
				`rsync -avzP rsync://hgdownload.cse.ucsc.edu/goldenPath/$spe/chromosomes/$address .`;
			}
			print STDERR "gunzip...\n";
			`gunzip $address`;
			
			push @name,basename($address, ".gz");
			sleep(5);
                }
        }
}
close IN;

my $name_str = join " ",@name;
`cat $name_str > genome.fa`;
`rm $name_str`;
`rm $spe.index $spe.log`;
print STDERR "remove temporary files.\n";

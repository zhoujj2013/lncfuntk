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

        Design for generate gene list for network construction.
        Author: zhoujj2013\@gmail.com
        Usage: $0 tf_f miRNA_f expr_gene_f index_f

USAGE
print "$usage";
exit(1);
};

my ($tf_f, $mirna_f, $expr_gene_f, $index_f) = @ARGV;

my %gene;
my %index;

open IN,"$index_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	my $type;
	if($t[2] eq "lncRNA"){
		$type = "lncRNA";
	}elsif($t[2] eq "protein coding gene"){
		$type = "pcg";
	}elsif($t[2] eq "miRNA"){
		$type = "miRNA";
	}else{
		next;
	}
	$index{$t[1]} = $type;
}
close IN;

open IN,"$expr_gene_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if(exists $index{$t[0]}){
		$gene{$t[0]} = $index{$t[0]};
	}else{
		print STDERR join "\t",@t,"\n";
	}
}
close IN;

open IN,"$mirna_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	if(exists $index{$t[0]}){
		$gene{$t[0]} = $index{$t[0]};
	}else{
		print STDERR join "\t",@t,"\n";
	}
}
close IN;

open IN,"$tf_f" || die $!;
while(<IN>){
    chomp;
    my @t = split /\t/;
    if(exists $index{$t[0]}){
        $gene{$t[0]} = "TF";
    }else{
        print STDERR join "\t",@t,"\n";
    }
}
close IN;

foreach my $g (keys %gene){
	print "$g\t$gene{$g}\n";
}


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
        Usage: $0 <db_dir> <mir_lst_f> <mirbase_mgi_f> <trans_level_inter_f>

USAGE
print "$usage";
exit(1);
};

my ($db_dir, $mir_lst_f, $mirbase_mgi_f, $trans_level_inter_f) = @ARGV;

# ignore the gene have no record in ensembl
my %mir;
open IN,"$mir_lst_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$mir{$t[1]} = $t[0];
}
close IN;

my @mirbase;
open IN,"$mirbase_mgi_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	push @mirbase,\@t;
}
close IN;

my %index;
open IN,"$db_dir/trans.index" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;	
	$index{$t[0]} = $t[1];
}
close IN;

my %inter;
open IN,"$trans_level_inter_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	# trans id to gene id
	my $target_gene_id =  "";
	my $origin_trans_id = $1 if($t[1] =~ /(.*)-\d+/);
	if(exists $index{$t[1]}){
		$target_gene_id = $index{$t[1]};
	}elsif(exists $index{$origin_trans_id}){
		$target_gene_id = $index{$origin_trans_id};
	}
	
	# miRNA id to ensembl id, if no ensembl id, use miRbase gene id instead
	my $mir_id = "";
	foreach my $l (@mirbase){
		my @mirbase_id = split /;/,$l->[-1];
		foreach my $mirbase_id (@mirbase_id){
			if(exists $mir{$t[0]} && $mirbase_id eq $mir{$t[0]}){
				$mir_id  = $l->[0];
			}
		}
	}
	
	# to skip some noisy
	if(exists $mir{$t[0]}){
		$mir_id = $mir{$t[0]} if($mir_id eq "");
	}else{
		print STDERR join "\t",@t,"\n";
		next;
	}
	
	#print "$mir_ensemble_id\t$target_ensembl_gene_id\t$t[2]\t$t[3]\t$t[4]\n";
	# store and clean interaction
	#print STDERR "$target_ensembl_gene_id\n" if($target_ensembl_gene_id eq "");
	$inter{$mir_id}{$target_gene_id} = [$t[2],$t[3],$t[4]];
}
close IN;

# print out the result
foreach my $m_id (keys %inter){
	foreach my $t_id (keys %{$inter{$m_id}}){
		print "$m_id\t$t_id\t";
		print join "\t",@{$inter{$m_id}{$t_id}};
		print "\n";
	}
}

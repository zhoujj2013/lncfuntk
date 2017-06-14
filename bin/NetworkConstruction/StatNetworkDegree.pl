#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;
#use lib "/home/zhoujj/my_lib/pm";
#use bioinfo;

&usage if @ARGV<1;

#open IN,"" ||die "Can't open the file:$\n";
#open OUT,"" ||die "Can't open the file:$\n";

sub usage {
        my $usage = << "USAGE";

        Description of this script.
        Author: zhoujj2013\@gmail.com
        Usage: $0 <interaction.txt> <gene_element.txt>

USAGE
print "$usage";
exit(1);
};

my ($inter_f,$element_type_f) = @ARGV;

my $inter = read_interaction([$inter_f]);

my %e;
open IN,"$element_type_f" || die $!;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$e{$t[0]}{'type'} = $t[2];
	# $e{$t[1]}{'type'} = $t[2];
}
close IN;

foreach my $k1 (keys %$inter){
	foreach my $k2 (keys %{$inter->{$k1}}){
		$e{$k1}{'out'} = 0 unless(defined $e{$k1}{'out'});
		$e{$k1}{'out'}++;
		$e{$k2}{'in'} = 0 unless(defined $e{$k2}{'in'});
		$e{$k2}{'in'}++;
		
		# store ocurrence
		if($e{$k1}{'type'} eq "miRNA"){
			$e{$k2}{'miRNA'} = 0 unless(defined $e{$k2}{'miRNA'});
			$e{$k2}{'miRNA'}++;
		}elsif($e{$k1}{'type'} eq "lncRNA"){
			$e{$k2}{'lncRNA'} = 0 unless(defined $e{$k2}{'lncRNA'});
			$e{$k2}{'lncRNA'}++;
		}elsif($e{$k1}{'type'} eq "pcg"){
			$e{$k2}{'pcg'} = 0 unless(defined $e{$k2}{'pcg'});
			$e{$k2}{'pcg'}++;
		}elsif($e{$k1}{'type'} eq "TF"){
			$e{$k2}{'tf'} = 0 unless(defined $e{$k2}{'tf'});
			$e{$k2}{'tf'}++;
		}
		
		if($e{$k2}{'type'} eq "miRNA"){
            $e{$k1}{'miRNA'} = 0 unless(defined $e{$k1}{'miRNA'});
            $e{$k1}{'miRNA'}++;
        }elsif($e{$k2}{'type'} eq "lncRNA"){
            $e{$k1}{'lncRNA'} = 0 unless(defined $e{$k1}{'lncRNA'});
            $e{$k1}{'lncRNA'}++;
        }elsif($e{$k2}{'type'} eq "pcg"){
            $e{$k1}{'pcg'} = 0 unless(defined $e{$k1}{'pcg'});
            $e{$k1}{'pcg'}++;
        }elsif($e{$k2}{'type'} eq "TF"){
            $e{$k1}{'tf'} = 0 unless(defined $e{$k1}{'tf'});
            $e{$k1}{'tf'}++;
        }
	}
}
#
#   1244 lncRNA
#       295 miRNA
#         14265 pcg
#            1195 tf
#
#print Dumper(\%e);
print "#gene_name\tin_degree\tout_degree\tall_degree\ttype\n";
print STDERR "#gene_name\tmiRNA\ttf\tpcg\tlncRNA\ttype\n";
foreach my $g (keys %e){
	$e{$g}{'out'} = 0 unless(defined $e{$g}{'out'});
	$e{$g}{'in'} = 0 unless(defined $e{$g}{'in'});
	$e{$g}{'miRNA'} = 0 unless(defined $e{$g}{'miRNA'});
	$e{$g}{'tf'} = 0 unless(defined $e{$g}{'tf'});
	$e{$g}{'pcg'} = 0 unless(defined $e{$g}{'pcg'});
	$e{$g}{'lncRNA'} = 0 unless(defined $e{$g}{'lncRNA'});

	my $all = $e{$g}{'out'} + $e{$g}{'in'};
	my $all_other = $e{$g}{'miRNA'} + $e{$g}{'tf'} + $e{$g}{'pcg'} + $e{$g}{'lncRNA'};
	print STDERR "$g\t$e{$g}{'miRNA'}\t$e{$g}{'tf'}\t$e{$g}{'pcg'}\t$e{$g}{'lncRNA'}\t$e{$g}{'type'}\n";
	print "$g\t$e{$g}{'in'}\t$e{$g}{'out'}\t$all\t$e{$g}{'type'}\n";
}


sub read_interaction{
    my ($arr_f) = @_;
    my %h;
    foreach my $f (@{$arr_f}){
        open IN,"$f" || die $!;
        while(<IN>){
            chomp;
            next if(/^#/);
            next if(/^\s*$/);
            my @t = split /\t/;
            $t[4] = "stage1" unless(defined $t[4]);
            $h{$t[0]}{$t[1]} = \@t;
        }
        close IN;
    }
    return \%h;
}



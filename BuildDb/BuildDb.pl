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

        Create reference database for LncFunNet analysis.
        Author: zhoujj2013\@gmail.com, Thu Apr 13 15:09:25 HKT 2017
        Usage: $0 <mm9|mm10|hg19|hg38> <outdir> [novel.lncrna.gtf] [new_db_name]
        
        # build db with integrating novel lncRNAs
	Example: perl $0 mm9 ./ novel_lncrna.gtf newdb > log 2>err

        # build db without integrating novel lncRNAs(build the NCBI refseq)
        Example: perl $0 mm9 ./ > log 2>err

USAGE
print "$usage";
exit(1);
};

my $software_version = "lncnet";

my $datestring = localtime();
print STDERR "$datestring\n";


if(scalar(@ARGV) == 2){
	my $spe = shift;
	my $outdir = shift;
	$outdir = abs_path($outdir);
	mkdir "$outdir" unless(-e "$outdir");
	#mkdir "$outdir/$spe" unless(-e "$outdir/$spe");
	
	print STDERR "Collect http/ftp addresses for each dataset: start\n";
	`perl $Bin/get_config_setting.pl $outdir/$spe.config.txt`;
	print STDERR "$outdir/$spe.config.txt\n";
	print STDERR "Collect http/ftp addresses for each dataset: done\n";
	
	print STDERR "Prepare dataset for $software_version analysis ($spe): start\n";
	`perl $Bin/build_db.pl $spe $outdir`;
	print STDERR "Prepare dataset for $software_version analysis ($spe): finished\n";
}elsif(scalar(@ARGV) == 4){
	my $spe = shift;
        my $outdir = shift;
        $outdir = abs_path($outdir);
	mkdir "$outdir" unless(-e "$outdir");
	#mkdir "$outdir/$spe" unless(-e "$outdir/$spe");
	
	my $gtf_f = shift;
	$gtf_f = abs_path($gtf_f);
	my $new_db_name = shift;
	
	print STDERR "Collect http/ftp addresses for each dataset: start\n";
	`perl $Bin/get_config_setting.pl $outdir/$spe.config.txt`;
	print STDERR "$outdir/$spe.config.txt\n";
	print STDERR "Collect http/ftp addresses for each dataset: done\n";
	
	print STDERR "Prepare dataset for $software_version analysis ($spe with novo lncRNAos): start\n";
	if(-d "$outdir/$new_db_name"){
		die "ERROR: $new_db_name exists. Please enter a new db name or remove the existing database $outdir/$new_db_name.\n";
	}
	# check whether the reference db have been build up.
	unless(-d "$outdir/$spe"){
		`perl $Bin/build_db.pl $spe $outdir`;
	}

	# build new database
	# Usage: ../bin/BuildDb/build_db_with_novel_lncrna.pl spe reference_db_dir novel_lncrna.gtf new_db_name outdir
	`perl $Bin/build_db_with_novel_lncrna.pl $spe $outdir/$spe $gtf_f $new_db_name $outdir > newdb.log 2>newdb.err`;
	print STDERR "Prepare dataset for $software_version analysis ($spe with novo lncRNAs): finished\n";
}else{
	&usage;
}

$datestring = localtime();
print STDERR "$datestring\n";

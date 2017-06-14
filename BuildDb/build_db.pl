#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;
use Cwd qw(abs_path);

&usage if @ARGV<1;

#open IN,"" ||die "Can't open the file:$\n";
#open OUT,"" ||die "Can't open the file:$\n";

sub usage {
        my $usage = << "USAGE";

        This script designed for building GO annoation database and geneset database.
        Author: zhoujj2013\@gmail.com
        Usage: $0 <species> <outdir>
        Example:perl $0 mm9 outdir > log 

USAGE
print "$usage";
exit(1);
};


my ($species,$outdir) = @ARGV;

# set up output dir
$outdir = abs_path($outdir);
mkdir "$outdir" unless(-e "$outdir");
#$outdir = "$outdir";


# read in the config file
print STDERR "\nRead in database sources: start\n";
print STDERR "$outdir/$species.config.txt\n";
my %config;
open IN,"$outdir/$species.config.txt" || die $!;
$/ = ">"; <IN>; $/ = "\n";
while(<IN>){
	chomp;
	next if(/^#/);
	my $id = $1 if(/(\S+)/);
	$/ = ">";
	my $seq = <IN>;
	chomp($seq);
	$/ = "\n";
	
	my @seq = split /\n/,$seq;
	# store the download config
	foreach(@seq){
		my ($data, $address) = ($1, $2) if($_ =~ /(.*)=(.*)/);
		$config{$id}{$data} = $address if($id eq $species);
	}
}
close IN;
print STDERR "Read in database sources: finished\n";

# set up Gene ontology database

print STDERR "\nDownloading files: start\n";
# ############################
# download the gbff files
# ############################
if(-d "$outdir/$species"){
	print STDERR "ERROR: $outdir/$species is exists, please delete it manually and re-run the program.\n";
	exit(1);
}
`mkdir $outdir/$species` unless(-d "$outdir/$species");
$outdir = "$outdir/$species";

foreach my $spe (keys %config){
	foreach my $data (keys %{$config{$spe}}){
		my $filename = basename($config{$spe}{$data});
		print STDERR "$config{$spe}{$data}";
		`wget $config{$spe}{$data} -O $outdir/$filename -o $outdir/$species.log` unless(-e "$outdir/".basename($config{$spe}{$data},".gz"));
		print STDERR " done\n";
		my $bn = basename($config{$spe}{$data});
		if($bn =~ /\.gz$/){
			my $bname = basename("$outdir/$bn", ".gz");
			while(1){
				print STDERR "gunzip ...\n";
				`gunzip $outdir/$bn`;
				unless(-f "$outdir/$bname"){
					`rm $outdir/$bn`;
					sleep 10;
					print STDERR "redownload: $config{$spe}{$data} ";
					`wget $config{$spe}{$data} -O $outdir/$filename -o $outdir/$species.log`;
					print STDERR "done\n";
				}else{
					last;
				}
			}
			
			# deal with goa
			if($data eq "goa"){
				`mv $outdir/$bname $outdir/goa.gaf`;
			}
		}
		
		if($bn =~ /\.gz$/){
			my $bn2 = basename($config{$spe}{$data}, ".gz");
			$config{$spe}{$data} = "$outdir/".$bn2;
		}else{
			$config{$spe}{$data} = "$outdir/".basename($config{$spe}{$data});
		}
		sleep 10;
	}
}
print STDERR "Downloading files: finished\n";

#print Dumper(\%config);

###########################################
# create the level1 and level2 go entries
###########################################
print STDERR "\nBuild GO term dataset: start\n";
`python $Bin/ReadOBO.py $config{$species}{"obo"} $species > $outdir/GO.level12.go`;
print STDERR "$species\n$outdir/GO.level12.go\n";
print STDERR "Build GO term dataset: finished\n";

###########################################
# create geneset database
# build refgene to gene.gtf
# #########################################
print STDERR "\nPrepare geneset for $species: start\n";
print STDERR "Convert refGene.txt to GTF format\n";
`perl $Bin/refGeneToGtf.pl $outdir/refGene.txt > $outdir/refGene.gtf`;
`perl $Bin/covertRefGeneToBed.pl $outdir/refGene.txt > $outdir/refGene.bed`;

# build refgene annotation from genebank
print STDERR "Extract transcript information from .gbff files.\n";
foreach my $spe (keys %config){
	foreach my $data (keys %{$config{$spe}}){
		`cat $config{$spe}{$data} >> $outdir/$species.rna.gbff` if($data =~ /^gbff/);
	}
}

`perl $Bin/getTransAnnoFromGenebank.pl $outdir/$species.rna.gbff >$outdir/refGene.anno.raw 2>$outdir/refGene.anno.raw.log`;

`perl $Bin/assign_genetype.pl $outdir/refGene.txt $outdir/refGene.anno.raw >$outdir/refGene.anno 2>$outdir/refGene.anno.log`;

`rm $outdir/$species.rna.gbff`;

# build exon, intron, 3utr, 5utr, CDS
`perl $Bin/GetElement/get_element.pl $outdir/refGene.txt $outdir/refGene.gtf  $outdir/refGene.anno $outdir/`;

print STDERR "Prepare geneset for $species: finished\n";

#################################
# build reference genome
# ###############################
my $current_dir = `pwd`;
chomp($current_dir);

print STDERR "\nPrepare genome sequence for $species: start\n";
chdir $outdir;
`perl $Bin/dl_ref_genome.pl $species`;
chdir $current_dir;
print STDERR "Prepare genome sequence for $species: finished\n";

#################################
## build reference miRNA database
## ###############################
print STDERR "\nPrepare miRNA annotation for $species: start\n";
chdir $outdir;
mkdir "miRNAdb" unless(-d "miRNAdb");
chdir "./miRNAdb";
`perl $Bin/miRNAdb/build_miRNAdb.pl $species`;
chdir $current_dir;
print STDERR "Prepare miRNA annotation for $species: finished\n";


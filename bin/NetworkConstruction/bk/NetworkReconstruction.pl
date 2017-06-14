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

        Network reconstruction pipeline. Results will output in current directory.
        Author: zhoujj2013\@gmail.com
        Usage: $0 config.txt

USAGE
print "$usage";
exit(1);
};

my ($config_f) = @ARGV;


my $config = read_config($config_f);

my $prefix = $config->{"Prefix"};

#print Dumper($config);

# 01 create the raw interaction
`mkdir ./01RawInteraction` unless(-e "./01RawInteraction");
my $InferredInt = join " ",@{$config->{"InferredInt"}};
my $DirectedInt = join " ",@{$config->{"DirectedInt"}};
`perl $Bin/CreateRawInteraction.pl $config->{"GeneList"} $DirectedInt $InferredInt > ./01RawInteraction/$prefix.Raw.int`;
`perl $Bin/CreateRawInteraction.pl  $config->{"GeneList"} $DirectedInt > ./01RawInteraction/$prefix.Directed.int`;
`perl $Bin/CreateRawInteraction.pl  $config->{"GeneList"} $InferredInt > ./01RawInteraction/$prefix.Inferred.int`;

# 02 assgin link score (this part need improve)
`mkdir ./02AssignScore` unless(-e "./02AssignScore");
#`perl $Bin/CreateRawInteraction.pl $config->{"GeneList"} $DirectedInt > ./02AssignScore/$prefix.directed.int`;
#`cat $InferredInt > ./02AssignScore/$prefix.inferred.int`;
`python $Bin/ResourceAllocationScore.py ./01RawInteraction/$prefix.Inferred.int ./01RawInteraction/$prefix.Directed.int > ./02AssignScore/$prefix.inferred.int.RA.scored`;

###################################
#foreach my $inferred (@{$config->{"InferredInt"}}){
#	foreach my $directed (@{$config->{"DirectedInt"}}){
#		`perl $Bin/CalcConfidentScore.pl $inferred $directed $config->{"GeneList"} >> ./02AssignScore/$prefix.coexpr.int`;
#	}
#}
#`perl $Bin/RemoveRedundantInt.pl ./02AssignScore/$prefix.coexpr.int > ./02AssignScore/$prefix.coexpr.clean.int`;
##################################

#`perl $Bin/CreateRawInteraction.pl $config->{"GeneList"} $DirectedInt $InferredInt > ./02AssignScore/$prefix.raw.int`;
`perl $Bin/CalcConfidentScore.pl ./01RawInteraction/$prefix.Raw.int ./01RawInteraction/$prefix.Directed.int ./01RawInteraction/$prefix.Inferred.int ./02AssignScore/$prefix.inferred.int.RA.scored > ./02AssignScore/$prefix.scored.int`;

# 03 Integrated network
`mkdir ./03IntegratedNetwork`  unless(-e "./03IntegratedNetwork");
`awk '\$4 >0.5 ' ./02AssignScore/$prefix.scored.int > ./03IntegratedNetwork/$prefix.scored.filtered.int`;

# 04 network stat
`mkdir ./04NetworkStat` unless(-e "./04NetworkStat");
chdir "./04NetworkStat";
`python $Bin/generalInformation.py ../03IntegratedNetwork/$prefix.scored.filtered.int $config->{"GeneList"} $prefix > summary.txt 2>log`;
chdir "..";

sub read_config{
	my ($cf) = @_;
	my %c;
	open IN,"$cf" || die $!;
	while(<IN>){
		chomp;
		next if(/(^#|^\s*$)/);
		#print "$_\n";
		my @t = split /=/;
		$t[1]=~ s/\s+//g;
		$t[0]=~ s/\s+//g;
		if($t[0] eq "InferredInt"){
			push @{$c{$t[0]}},$t[1];
		}elsif($t[0] eq "DirectedInt"){
			push @{$c{$t[0]}},$t[1];
		}else{
			$c{$t[0]} = $t[1];
		}
	}
	close IN;
	return \%c;
}

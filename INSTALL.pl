#!/usr/bin/perl -w

use strict;

my $result = 1;

print "#####################################################\n";
my $logo = << "LOGO";
  _            ______        _______ _  __
 | |          |  ____|      |__   __| |/ /
 | |_ __   ___| |__ _   _ _ __ | |  | ' / 
 | | '_ \\ / __|  __| | | | '_ \\| |  |  <  
 | | | | | (__| |  | |_| | | | | |  | . \\ 
 |_|_| |_|\\___|_|   \\__,_|_| |_|_|  |_|\\_\\

Version: 1.0
Github: https://github.com/zhoujj2013/lncfuntk
Email: zhoujiajian\@link.cuhk.edu.hk                                          
LOGO
print $logo;
print "#####################################################\n\n";
print "Check lncFunTK dependencies:\n\n";
# for perl
my $perl_version = $];
if($perl_version >= 5.0){
	print "Perl $perl_version is installed.\n";
}else{
	print "Perl > 5.0 not exists.\n";
	$result = 0;
}

# python
my $python_version = `python --version 2>&1`;
chomp($python_version);

if($python_version =~ /Python 2.7/){
	print "$python_version is installed.\n";
}else{
	print "Python 2.7 not exists.\n";
	$result = 0;
}

# for python pakages
print "\n";
my $mlist = `python -m pip freeze`;
my @mlist = split /\n/,$mlist;

my %mlist;
foreach my $m (@mlist){
	my ($m_name,$m_version) = split /==/,$m;
	$mlist{$m_name} = $m_version;
}

if(exists $mlist{'matplotlib'}){
	print "matplotlib==$mlist{'matplotlib'} is installed.\n";
}else{
	print "matplotlib not exists. Please install matplotlib by pip.\n";
	$result = 0;
}


if(exists $mlist{'networkx'}){
	print "networkx==$mlist{'networkx'} is installed.\n";
}else{
        print "networkx not exists. Please install networkx by pip.\n";
	$result = 0;
}


if(exists $mlist{'numpy'}){
	print "numpy==$mlist{'numpy'} is installed.\n";
}else{
        print "numpy not exists. Please install numpy by pip.\n";
	$result = 0;
}



if(exists $mlist{'scikit-learn'}){
	print "scikit-learn==$mlist{'scikit-learn'} is installed.\n";
}else{
        print "scikit-learn not exists. Please install scikit-learn by pip.\n";
	$result = 0;
}


if(exists $mlist{'scipy'}){
	print "scipy==$mlist{'scipy'} is installed.\n";
}else{
        print "scipy not exists. Please install scipy by pip.\n";
	$result = 0;
}


if(exists $mlist{'statsmodels'}){
	print "statsmodels==$mlist{'statsmodels'} is installed.\n";
}else{
        print "statsmodels not exists. Please install statsmodels by pip.\n";
	$result = 0;
}
print "\n";

# download database

if(-d "./data/mm9"){
	print "Supporting dataset is exists. skipped.\n";
	print "if you want to update the supporting dataset. Please remove ./data/mm9 and re-run $0\n\n";
}else{
	print "Download supporting dataset for mouse(mm9): start.\n";
	print "Please have a cup of coffee, it will take some time.\n";
	chdir "data/";
	`wget http://137.189.133.71/zhoujj/lncfuntk/mm9.tar.gz && touch mm9.dl.log`;
	`tar xzf mm9.tar.gz`;
	`rm mm9.dl.log mm9.tar.gz`;
	chdir "..";
	print "Download supporting dataset: done.\n\n";
}
# prepare demo data
print "Prepare dataset for demo: start.\n";
chdir "./demo/test_data";
`sh prepare.sh`;
chdir "..";
chdir "..";
print "Prepare dataset for demo: done.\n\n";


if($result == 0){
	print "Installation not completed. Please recheck the dependencies.\n";
}else{
	print "Cheers. Installation completed.\n\n";
	print "Please test lncFunTK as follow:\n\n";

	my $test_cmd = << "CMD";
	cd ./demo
	perl ../run_lncfuntk.pl config.txt
	# then make the file
	make
	# around 15 mins.
	# you can check the report (index.html) in 07Report directory.
	cd 07Report
	firefox ./index.html
CMD
	print "$test_cmd";
	print "\n#####################################################\n";
}


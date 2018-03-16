#!/usr/bin/perl -w

use strict;
use LWP::Simple;
use Getopt::Long;

sub usage {
        my $usage = << "USAGE";

        Install or update lncFunTK.
        Author: zhoujiajian\@link.cuhk.edu.hk
        Last updated: 24th Feb. 2018

        --install  install lncFunTK(included mm9 database by default).
        --update   update database.
        --db <str> initial or update database [mm9, mm10, hg19, hg38].
        --help     print this message.

USAGE
print "$usage";
exit(1);
};

my ($install,$update, $db, $help);
GetOptions(
	"install"=>\$install,
	"update"=>\$update,
	"db:s"=>\$db,
	"help"=>\$help
);

if((!$install && !$db) || (@ARGV <= 0 && !$install && !$db)|| $help){
	&usage;
}

if($install){
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
	
	# check network
	print "#####################################################\n";
	print "Check your network status:\n\n";
	my $query = "http://137.189.133.71/lncfuntk/";
	my $browser = LWP::UserAgent->new;
	my $response = $browser->get( $query );
	
	if($response->code == 200){
		print "The network is OK!\n\n";
	}else{
		print "The network is not available!\nPlease recheck your network status.\n\n";
		exit(1);
	}
	
	print "#####################################################\n";
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
	my $mlist = `pip freeze`;
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
	
	if($result == 0){
		print "Install or updating python packages: start\n";
		`pip install -r  ./python.package.requirement.txt --user`;
		print "Install or updating python packages: finished\n\n";
		
		print "You also can install require python packages at a time by the following command:\n";
		print "pip install -r  ./python.package.requirement.txt --user\n\n";
		print "For more detials, please refer to: https://github.com/zhoujj2013/lncfuntk\n\n";
	}
	
	# download database
	print "#####################################################\n";
	if(-d "./data/mm9"){
		print "Supporting dataset is exists. skipped.\n";
		print "if you want to update the supporting dataset. Please remove ./data/mm9 and re-run $0\n\n";
	}else{
		print "Download supporting dataset for mouse(mm9): start.\n";
		print "Please have a cup of coffee, it will take some time.\n";
		chdir "data/";
		`wget http://137.189.133.71/zhoujj/lncfuntk/mm9.tar.gz && wget http://137.189.133.71/zhoujj/lncfuntk/mm9.tar.gz.md5 && touch mm9.dl.log`;
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
}

if(!$install && $db){
	if(-d "./data/$db" && $update){
		print "Check updates for $db: start.\n";
		`wget -O tmp.md5 http://137.189.133.71/zhoujj/lncfuntk/$db.tar.gz.md5`;
		
		my $new_md5;
		open IN,"tmp.md5"|| die $!;
		while(<IN>){
			chomp;
			my @t = split /\s+/;
			$new_md5 = $t[0];
		}
		close IN;
		`rm tmp.md5`;	
		my $old_md5;
		open IN,"./data/$db.tar.gz.md5"|| die $!;
		while(<IN>){
			chomp;
			my @t = split /\s+/;
			$old_md5 = $t[0];
		}
		close IN;
		
		if($new_md5 eq $old_md5){
			print "Current version is up-to-date.\n";
		}else{
			chdir "data/";
			`rm $db.tar.gz.md5`;
			`rm -r $db`;
			`wget http://137.189.133.71/zhoujj/lncfuntk/$db.tar.gz && wget http://137.189.133.71/zhoujj/lncfuntk/$db.tar.gz.md5 && touch $db.dl.log`;
			`tar xzf $db.tar.gz`;
			`rm $db.dl.log $db.tar.gz`;
			chdir "..";
		}
		print "Update supporting dataset: done.\n\n";

	}elsif(!(-d "./data/$db")){
		print "Download supporting dataset for $db: start.\n";
		print "Please have a cup of coffee, it will take some time.\n";
		chdir "data/";
		`wget http://137.189.133.71/zhoujj/lncfuntk/$db.tar.gz && wget http://137.189.133.71/zhoujj/lncfuntk/$db.tar.gz.md5 && touch $db.dl.log`;
		`tar xzf $db.tar.gz`;
		`rm $db.dl.log $db.tar.gz`;
		chdir "..";
		print "Download supporting dataset: done.\n\n";
	}else{
		print "$db is exists (./data/$db).\n";
	}
}

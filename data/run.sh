# for example
wget ./mm9.tar.gz
tar xzvf mm9.tar.gz

# add novo lncRNAs and create new database, the new db will created (./newdb).
## perl bin/BuildDb/BuildDb.pl mm9 ./ novel_lncrna.gtf newdb > log 2>err

# update the database for mm9, mm10, hg19, hg38
## rm -r mm9
## perl bin/BuildDb/BuildDb.pl mm9 ./ > log 2>err

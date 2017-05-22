# lncnet
Functional characterization of lncRNA by integrative network analysis.

## Installation

### Get lncnet
```
git clone git@github.com:zhoujj2013/lncnet.git
```

### Install require python packages

lncnet written by [PERL](https://www.perl.org/). It require python 2.7.X or above and several python packages: matplotlib, networkx, numpy, scikit-learn, scipy, statsmodels etc. These python packages can be installed by pip online.

If you don't have pip, please download [get-pip.py](https://bootstrap.pypa.io/get-pip.py), then type:

```
python get-pip.py
```

Install python packages one by one using pip module:

```
cd lncnet
python -m  pip install -r  $INSTALL_DIR/python.package.requirement.txt --user 
```

You can also can run it in virtual environment, if you don't have superuser privilege.

```
# install virtualenv
pip install virtualenv

cd my_project_folder
virtualenv venv
source venv/bin/activate
python -m  pip install -r  $INSTALL_DIR/python.package.requirement.txt
```


## Build database

We need to prepare dataset for each genome, lncnet analysis rely on these datasets. Through BuildDb.pl, we can download dataset from UCSC, NCBI, EBI, mirBase and prepare these dataset for lncnet analysis automatically.

### Build reference database without denovo lncRNA assembly

At present, we support preparing dataset for mouse(mm9) and human(hg19).

```
cd $INSTALL_DIR
mkdir data
cd data
perl ../BuildDb/BuildDb.pl mm9 ./ > mm9.log
# this program will download the reference data from public databases.
```

### Build reference database with denovo lncRNA assembly

At present, we support preparing dataset for mouse(mm9) and human(hg19).

```
cd ./lncFNTK
mkdir data
cd data
perl ../BuildDb/BuildDb.pl mm9 ./ novel.final.gtf newdb >mm9.log 2>mm9.err
```

## Run testing

Run demo to check whether the package work well.

### Create database

If you haven't built database for mouse(mm9), please run:

```
cd data
perl ../BuildDb/BuildDb.pl mm9 ./
# around 20 mins
```

### Prepare test data for demo

```
cd $INSTALL_DIR
cd demo
cd demo/test_data
# prepare test dataset
sh prepare.sh
cd ..
# around 3 seconds
```

### Write the configure file

You should replace $DBDIR with the directory you create reference database in config.txt.
```
vim config.txt
# replace $DBDIR with the directory you create reference database
```

### Run testing

```
perl ../run_lncnet.pl config.txt
# then make the file
make
# around 15 mins.
```

## Input files

### expr.lst
```
stage1<tab>geneexpr.table1
stage2<tab>geneexpr.table2
...
stageN<tab>geneexpr.tableN
```
### tf.chipseq.lst
```
TF1_gene_symbol<tab>TF1.binding.peaks.bed
TF2_gene_symbol<tab>TF2.binding.peaks.bed
...
TFn_gene_symbol<tab>TFn.binding.peaks.bed
```
### MirRNA_expr_refseq.lst
```
miRNA1_symbol<tab>refseq_id1
miRNA2_symbol<tab>refseq_id2
...
miRNAn_symbol<tab>refseq_idn
```

## Output

### Co-expression network
```
01CoExprNetwork/prefix.CoExpr.int
```
### TF regulatory network
```
02TfNetwork/TfNetwork.int
```
### MiRNA-gene regulatory network
```
03MirnaNetwork/prefix.MirTargetGeneLevel.txt
```
### Integrative gene regulatory network
```
04NetworkConstruction/04NetworkStat/mESCs.int.txt
```
### Predicted functional lncRNA and nonfunctional lncRNAs
```
05FunctionalityPrediction/functional.lncrna.lst
05FunctionalityPrediction/nonfunctional.lncrna.lst
```
### lncRNA annotation
```
06FunctionalAnnotation/lncFunNet.GO.enrich.result.txt
```

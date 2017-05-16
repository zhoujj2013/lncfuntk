# lncnet
Functional characterization of lncRNA by integrative network analysis.

## Installation

### Get the code
```
git clone git@github.com:zhoujj2013/lncFNTK.git
```
### Install require python packages

If you don't have pip, please download [get-pip.py](https://bootstrap.pypa.io/get-pip.py), then type:

```
python get-pip.py
```

Install python packages one by one by pip:

```
cd lncFNTK
pip install ./bin/python.package.requirement.txt
```

### Run testing

Run test.sh to check the package work well.(I'm still working on this.)

## Build database

### Build reference database without denovo lncRNA assembly
```
cd ./lncFNTK
mkdir data
cd data
perl ../bin/BuildDb/build_db.pl mm9 ./ > mm9.log
# this program will download the reference data from public databases.
```
### Build reference database with denovo lncRNA assembly
```
cd ./lncFNTK
mkdir data
cd data
perl ../bin/BuildDb/build_db.pl mm9 ./ novel.final.gtf newdb >mm9.log 2>mm9.err
```

## Run LncFunNet analysis in one step

### Prepare config.txt

To find the format for config.txt file, please refer to "../bin/config.txt"

For example:

```
OUTDIR  ./
PREFIX  mESCs

# human/mouse
SPE     mouse

# genome version
VERSION mm9

# dbname for this analysis
DB      ./data/mm9

# time serise transcriptome profiles(multiple datasets, place the major at first, at least 3 datasets)
EXPR    ./data/expr.lst

# the expression profile column corresponsing to the cell stage that you want
# to prediction long nocoding RNA
EXPRCUTOFF      0.5
PCCCUTOFF       0.95

# TF binding peaks from TF chipseq (multiple datasets, at least the key tfs)
CHIP    ./data/tf.chipseq.lst
PROMTER 10000,5000

# Ago2 binding site from CLIP-seq (1 dataset)
CLIP    ./data/Ago2.binding.bed
EXTEND  100

# express miRNA list
MIRLIST ./data/MirRNA_expr_refseq.lst
```

### Perform the analysis

Generate Makefile for lncFunNet analysis, run the analysis.
```
perl ../bin/Run_lncFNTK.pl config.txt > lncFNTK.log
make > mk.log 2>mk.err
# this process will run a half day, please be patient.
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


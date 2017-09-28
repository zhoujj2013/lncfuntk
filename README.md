# lncFunTK
LncRNA Functional annotation ToolKit with integrative network analysis.

## Installation

### Get lncFunTK
```
git clone https://github.com/zhoujj2013/lncfuntk.git
```

### Dependencies

lncFunTK written by [PERL](https://www.perl.org/) and [python](https://www.python.org/). It requires python 2.7, Perl5 and several python packages: matplotlib, networkx, numpy, scikit-learn, scipy, statsmodels etc. These python packages can be installed through [pip](https://pypi.python.org/pypi/pip).

If you don't have pip, please download get-pip.py from https://bootstrap.pypa.io/get-pip.py and install pip module with [instructions](https://pip.pypa.io/en/stable/installing/):

```
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
python get-pip.py
```

Install python packages using pip module:

```
cd lncfuntk
python -m  pip install -r  ./python.package.requirement.txt --user
```

You can also run it in python virtual environment, if you don't have superuser privilege.

```
# install virtualenv
pip install virtualenv

cd my_project_folder
virtualenv venv
source venv/bin/activate

# $INSTALL_DIR represent the lncfuntk install directory.
python -m  pip install -r  $INSTALL_DIR/python.package.requirement.txt
```
### Installation

If everything is ready, run command as follow:

```
cd ./lncfuntk
perl INSTALL.pl
# installation finished.
```

## Obtain supporting dataset

Additional dataset are needed for lncFunTK analysis. They are downloaded from from UCSC, NCBI, EBI, mirBase and preprocessed by BuildDB module. You can obtain supporting datasets for [mm9](http://137.189.133.71/zhoujj/lncfuntk/mm9.tar.gz), [mm10](http://137.189.133.71/zhoujj/lncfuntk/mm10.tar.gz), [hg19](http://137.189.133.71/zhoujj/lncfuntk/hg19.tar.gz), [hg38](http://137.189.133.71/zhoujj/lncfuntk/hg38.tar.gz) from our server or the newest version from public databases by BuildDB module.

### Download supporting dataset

At present, we support downloading dataset for mouse(mm9, mm10) and human(hg19, hg38).

```
cd ./lncfuntk
cd data
wget http://137.189.133.71/zhoujj/lncfuntk/mm9.tar.gz
tar xzvf mm9.tar.gz
```

### Add newly assembled lncRNAs to supporting dataset

After you download supporting dataset from our server and untar it, you can add newly assembled lncRNAs to investigate their functionality.

```
cd ./lncfuntk
cd data
perl ../bin/BuildDb/BuildDb.pl mm9 ./ novel.lncRNA.gtf newdb >mm9.log 2>mm9.err
```

Note: "novel.lncRNA.gtf" represents newly assembled lncRNA in [gtf](http://www.ensembl.org/info/website/upload/gff.html) format. "newdb" represents the name of supporting datasets with newly assembled lncRNAs added.

### Create the latest supporting datasets

We will update supporting datasets in our server every 3 months. If you want to download the latest supporting dataset, you can build it by yourself with BuildDB module in lncFunTK package.

```
cd data
# if mm9 directory is exists.
rm -r mm9
perl ../bin/BuildDb/BuildDb.pl mm9 ./ > mm9.log
# this program will download the latest supporting datasets from public databases.
# Be patient, at least 30 mins are needed for this step.
```
## Training optimal weight values for FIS calculation

We designed Training.pl utility script for the user to obtain optimal weight values for FIS calculation by learning from a user provided training dataset (i.e., a set of func-tional lncRNAs and nonfunctional lncRNAs), if the user thinks that the default weight matrix is not suitable for their system. 

You should prepared 3 files for training:

1. a list of functional lncRNAs as positive dataset;
2. a list of nonfunctional lncRNAs (with expression FPKM > 0.05) as negative dataset;
3. Neighbor counts for each lncRNA within the integrative regulatory network;

Then, train the optimal parameters for lncFunNet as follow:

```
cd $lncFunTK_install_dir/demo/training/
perl $lncFunTK_install_dir/bin/Training/Training.pl XXXX.Neighbor.stat postive.lst negative.lst

# result files:
# LR.weight.value.lst
# LR.png
```

LR.result file stored the optimal weight values for FIS calculation, which can directly be used as the input for FunctionalityPrediction.pl ($lncFunTK_install_dir/bin/FunctionalityPrediction/FunctionalityPrediction.pl).

## Run demo

Once you installed the lncFunTK package and obtained the supporting datasets, you can run demo to examine whether the package works well (the test dataset is placed in ./demo directory within lncFunTK).

```
cd demo
# create makefile
perl ../run_lncfuntk.pl config.txt
# then make the file
make

# around 15 mins.
# you can check the report (index.html) in 07Report.
firefox ./07Report/index.html
```
LncFunTK have been tested in CentOS release 6.2, Debian 7.0 3.2.60-1+deb7u3.

## Run lncFunTK analysis on your own data

To run lncFunTK analysis on your data, you need to prepare input dataset as we described in [Input files section](#input-files), then run lncFunTK as we described in [run demo section](#run-demo). Finally, you can check lncFunTK analysis result in 07Report directory. For more details about lncFunTK output, please refer to [Output files section](#output-files).

## Input files

You need to provide the input files in configure file:
1.	Gene expression profile (gene.expr.lst, a serial of RNA-seq analysis);
2.	TFs binding profiles(tf.chipseq.lst, from multiple TF ChiPseq analysis);
3.	Potential miRNA binding profile (miRNA.binding.potential.bed, from Ago CLIP-seq analysis);
4.	A list of expressed miRNA (MirRNA_expr_refseq.lst).
These files should be prepared in a similar directory as used for demo:

```
./
├── config.txt
└── test_data
    ├── GeneExpressionProfiles
    │   ├── CM.expr
    │   ├── CP.expr
    │   ├── EM.expr
    │   ├── gene.expr.lst
    │   └── mESCs.expr
    ├── MirnaBindingProfiles
    │   └── miRNA.binding.potential.bed
    ├── MirRNA_expr_refseq.lst
    ├── prepare.sh
    └── TfBindingProfiles
        ├── Brd4.bed
        ├── Esrrb.bed
        ├── Klf4.bed
        ├── Nanog.bed
        ├── Nr5a2.bed
        ├── Pou5f1.bed
        ├── Prdm14.bed
        ├── Smad3.bed
        ├── Sox2.bed
        ├── Stat3.bed
        ├── Tcf3.bed
        ├── tf.chipseq.lst
        └── Tfcp2l1.bed
```

### Gene expression profiles (GeneExpressionProfiles/gene.expr.lst)

Contain expression profiles from different stages.

```
stage1<tab>geneexpr.table1 (the corresponding expression profile for stage1)
stage2<tab>geneexpr.table2
...
stageN<tab>geneexpr.tableN
```

The file format for expression table file:

```
geneid1<tab>rpkm1 (the corresponding expression level for geneid1)
geneid2<tab>rpkm2
...
geneidN<tab>rpkmN
```

### TF binding profiles (TfBindingProfiles/tf.chipseq.lst)

Contain key transcription factor binding profiles.

```
TF1_gene_symbol<tab>TF1.binding.peaks.bed (the corresponding binding profile for TF1)
TF2_gene_symbol<tab>TF2.binding.peaks.bed
...
TFn_gene_symbol<tab>TFn.binding.peaks.bed
```

The input binding profile is in [bed format](https://genome.ucsc.edu/FAQ/FAQformat.html#format1), the fourth column should be unique binding IDs.

### Mirna binding profiles (MirnaBindingProfiles/miRNA.binding.potential.bed)

A list of potential miRNA binding sites in bed format.(Note: the fourth column should be a unique ID.)

```
# chrom<tab>start<tab>end<tab>id
chr1  234 289 mESCs_001
chr1  2834 2890 mESCs_002
...
```

### Expressed miRNA list (MirRNA_expr_refseq.lst)

Contain the expressed microRNAs.
The format is shown as following:

```
miRNA1_symbol<tab>refseq_id1 (Corresponding miRNA transcript id in RefSeq database for miRNA1_symbol)
miRNA2_symbol<tab>refseq_id2
...
miRNAn_symbol<tab>refseq_idn
```
### Configuration file (config.txt)
The configuration file is formatted as follow:

```
# setting output dir
OUTDIR  ./

# setting output result prefix
PREFIX  mESCs

# setting species information (human or mouse)
SPE     mouse

# genome version
VERSION mm9

# dbname for this analysis, you should replace $DBDIR
DB      ../data/mm9

# time serise transcriptome profiles(multiple datasets, place the major at first, at least 3 datasets)
EXPR    ./test_data/GeneExpressionProfiles/gene.expr.lst

# the expression profile column corresponsing to the cell stage that you want
# to prediction long nocoding RNA
EXPRCUTOFF      0.5
PCCCUTOFF       0.95

# TF binding peaks from TF chipseq (multiple datasets, at least the key tfs)
CHIP    ./test_data/TfBindingProfiles/tf.chipseq.lst
PROMTER 10000,5000

# Ago2 binding site from CLIP-seq (1 dataset)
CLIP    ./test_data/MirnaBindingProfiles/miRNA.binding.potential.bed
EXTEND  100

# express miRNA list, must be office gene symbol and corresponding transcript
# ID (with NR_ prefix)
MIRLIST ./test_data/MirRNA_expr_refseq.lst
```

## Output files

### LncFunTK analysis report

You can visualize LncFunTK analysis result by:

```
firefox index.html # or open in firefox browser
```
[demo](http://137.189.133.71/zhoujj/lncfuntk/demo/07Report/)

### Co-expression network

This plain text file contains co-expression network information by co-expression analysis of expression profile in multiple stages.

```
01CoExprNetwork/prefix.CoExpr.int
```

Format:

```
gene1<tab>gene2<tab>interaction_type<tab>score<tab>evidence
...
```

### TF regulatory network

This plain text file contains TF regulatory network information by analyzing multiple TF binding profiles.

```
02TfNetwork/TfNetwork.int
```

The format is the same as Co-expression network.

### MiRNA-gene regulatory network

This plain text file contains microRNA-gene interactions by analyzing Ago2 CLIP binding profile.

```
03MirnaNetwork/prefix.MirTargetGeneLevel.txt
```

The format is the same as Co-expression network.

### Integrative gene regulatory network

Contain all the interactions between 2 genes.
```
07Report/GeneRegulatoryNetwork.interaction.txt
```

The format is the sample as Co-expression network.

### Predicted functional lncRNAs and their annotation

Predicted functional lncRNAs and the corresponding FIS (Functional Information Score):

```
05FunctionalityPrediction/functional.lncrna.lst
05FunctionalityPrediction/nonfunctional.lncrna.lst
```

The format:

```
lncRNA_id1<tab>FIS1 (Corresponding Functional Information Score (FIS) for corresponding lncRNAs)
lncRNA_id2<tab>FIS2
...
lncRNA_idN<tab>FISN
```

GO annotation result for each predicted functional lncRNAs:
```
07Report/FunctionalLncRNA.txt
```

The format:

```
id1<tab>FIS1<tab>GoTermId<tab>GO DESC<tab>pvalue<tab>adjust-pvalue<tab>neighbor genes
```

## Please cite

1. Zhou J, Zhang S, Wang H, et al. LncFunNet: an integrated computational framework for identification of functional long noncoding RNAs in mouse skeletal muscle cells[J]. Nucleic Acids Research, 2017. PMID: [28379566](https://www.ncbi.nlm.nih.gov/pubmed/28379566).

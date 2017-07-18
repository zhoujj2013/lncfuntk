# lncFunTK
LncRNA Functional annotation toolkit with integrative network analysis.

## Installation

### Get lncFunTK
```
git clone https://github.com/zhoujj2013/lncfuntk.git
```

### Install require python packages

lncFunTK written by [PERL](https://www.perl.org/) and [python](https://www.python.org/). It require python 2.7.X or above and several python packages: matplotlib, networkx, numpy, scikit-learn, scipy, statsmodels etc. These python packages can be installed by [pip](https://pypi.python.org/pypi/pip).

If you don't have pip, please download get-pip.py from https://bootstrap.pypa.io/get-pip.py and install pip module with [instructions](https://pip.pypa.io/en/stable/installing/):

```
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
python get-pip.py
```

Install python packages one by one using pip module:

```
cd lncfuntk
python -m  pip install -r  $INSTALL_DIR/python.package.requirement.txt --user 
```

You can also can run it in python virtual environment, if you don't have superuser privilege.

```
# install virtualenv
pip install virtualenv

cd my_project_folder
virtualenv venv
source venv/bin/activate
python -m  pip install -r  $INSTALL_DIR/python.package.requirement.txt
```


## Obtain supporting dataset

Additional dataset is needed for lncFunTK analysis. Those dataset were downloaded from from UCSC, NCBI, EBI, mirBase and were preprocessing these dataset automatically by BuildDB module. You can obtain supporting dataset for [mm9](http://137.189.133.71/zhoujj/lncfuntk/mm9.tar.gz), [mm10](http://137.189.133.71/zhoujj/lncfuntk/mm10.tar.gz), [hg19](http://137.189.133.71/zhoujj/lncfuntk/hg19.tar.gz), [hg38](http://137.189.133.71/zhoujj/lncfuntk/hg38.tar.gz) from our server and you also can get the newest version from public databases by BuildDB module.

### Download supporting dataset

At present, we support downloading dataset for mouse(mm9, mm10) and human(hg19, hg38).

```
cd ./lncfuntk
cd data
wget http://137.189.133.71/zhoujj/lncfuntk/mm9.tar.gz
tar xzvf mm9.tar.gz
```

### Add denovo assembled lncRNAs to supporting dataset

After you download supporting dataset from our server and untar it, you can add new assembled lncRNAs to supporting dataset, so that you can investigate functionality of novel lncRNAs.

```
cd ./lncfuntk
cd data
perl ../bin/BuildDb/BuildDb.pl mm9 ./ novel.lncRNA.gtf newdb >mm9.log 2>mm9.err
```

Note: "novel.lncRNA.gtf" represent new assembled lncRNA in [gtf](http://www.ensembl.org/info/website/upload/gff.html) format. "newdb" represent for the name of supporting dataset that added new assembled lncRNAs.

### Create the latest supporting data

We will update supporting dataset in our server every 3 months. If you want to download the latest supporting dataset, you can build it by yourself with BuildDB module in lncFunTK package.

```
cd data
# if mm9 directory is exists.
rm -r mm9
perl ../bin/BuildDb/BuildDb.pl mm9 ./ > mm9.log
# this program will download the reference data from public databases.
# Be patient, at least 30 mins are needed for this step.
```

## Run demo

After you installed the lncFunTK package, you can run demo to check whether the package work well (the data was well prepared in ./demo).

### Create database

If you haven't built database for mouse(mm9), please run:

```
cd ./lncfuntk
cd data
wget http://137.189.133.71/zhoujj/lncfuntk/mm9.tar.gz
tar xzvf mm9.tar.gz
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

### Run lncFunTk analysis

```
perl ../run_lncfuntk.pl config.txt
# then make the file
make
# around 15 mins.
# you can check the report (index.html) in 07Report.
firefox ./index.html
```

## Run lncFunTK analysis on your data

To run lncFunTK analysis on your biological system, you need to prepare input dataset as we described in [Input files section](#input-files), then run lncFunTK as we described in [run demo section](#run-demo). Finally, you can check lncFunTK analysis result in 07Report directory. For more details about lncFunTK output, please reference to [Output files section](#output-files).

## Input files

We need to provide the input files in configure file. We listed the files as follow: 
1. Gene expression profile (gene.expr.lst, from time serise RNA-seq analysis);
2. TFs binding profiles(tf.chipseq.lst, from multiple TF chipseq analysis);
3. Potential miRNA binding profile (miRNA.binding.potential.bed, from Ago CLIP-seq analysis);
3. a list of express miRNA (MirRNA_expr_refseq.lst).

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

A list of potential miRNA binding site in bed format.(Note: the fourth column should be a unique ID.)

```
# chrom<tab>start<tab>end<tab>id
chr1  234 289 mESCs_001
chr1  2834 2890 mESCs_002
...
```

### Express miRNA list (MirRNA_expr_refseq.lst)

Contain the express microRNAs.

The format showed as follow:

```
miRNA1_symbol<tab>refseq_id1 (Corresponding miRNA transcript id in RefSeq database for miRNA1_symbol)
miRNA2_symbol<tab>refseq_id2
...
miRNAn_symbol<tab>refseq_idn
```

## Output files

### LncFunTK analysis report

You can visualize LncFunTK analysis result by:

```
firefox index.html # or open in firefox browser
```
[demo](http://137.189.133.71/zhoujj/lncfuntk/demo/07Report/)

### Co-expression network

This plain text file contain co-expression network information by co-expression analysis of expression profile in multiple stages.

```
01CoExprNetwork/prefix.CoExpr.int
```

Format:

```
gene1<tab>gene2<tab>interaction_type<tab>score<tab>evidence
...
```

### TF regulatory network

This plain text file contain TF regulatory network information by multiple TF binding profiles analysis.

```
02TfNetwork/TfNetwork.int
```

The format is the same as Co-expression network.

### MiRNA-gene regulatory network

This plain text file contain microRNA-gene interactions by analysis Ago2 CLIP binding profile.
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

Predicted functional lncRNAs and corresponding FIS. 

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

GO annotation result for each predicted functional lncRNAs.
```
07Report/FunctionalLncRNA.txt
```

The format:

```
id1<tab>FIS1<tab>GoTermId<tab>GO DESC<tab>pvalue<tab>adjust-pvalue<tab>neighbor genes
```

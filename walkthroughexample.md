# Run lncFunTK analysis on your own datasets

To run lncFunTK analysis on your own datasets, you need to prepare input dataset as described in [Input files section](#1-input-files-preparation), then run lncFunTK as described in [run section](#run-lncfuntk). Finally, you can check lncFunTK analysis result in 07Report directory. For more details, please refer to [Output files section](#4-explaination-of-result).

## 1. Input file preparation

### 1.1 Gene expression matrix from RNA-seq

Gene expression level of each stage can be quantified by RNA-seq data, then combine expression profiles from different stages into a matrix in plain text (i.e. [gene.expr.mat](https://github.com/zhoujj2013/lncfuntk/blob/master/demo/test_data/GeneExpressionProfiles/gene.expr.mat)).

Each column represents a gene expression profile in one stage.

### 1.2 Transcription Factor (TF) binding peaks from ChIP-seq

TF ChIP-seq data is aligned to reference genome, then TF binding peaks is called by MACS2. TF binding profiles are in [BED format](https://genome.ucsc.edu/FAQ/FAQformat.html#format1) are used in lncFunTK analysis.

TF binding profiles list must arange into plain text format (the first column is TF gene symbol, the second column is the absolute path of the corresponding TF binding profile in BED format (i.e. tf.chipseq.lst (https://github.com/zhoujj2013/lncfuntk/blob/master/demo/test_data/TfBindingProfiles/tf.chipseq.lst)).

### 1.3 Ago2 binding peaks from CLIP-seq

Ago2 CLIP-seq data is aligned to reference genome by bowtie2, then Ago2 potential binding peaks is called by [piranha](http://smithlabresearch.org/software/piranha/) or [CIMS](https://zhanglab.c2b2.columbia.edu/index.php/CTK_Documentation) analysis. 

Ago2 binding peaks in BED format is used as input file of lncFunTK (i.e. [miRNA.binding.potential.bed](https://github.com/zhoujj2013/lncfuntk/blob/master/demo/test_data/MirnaBindingProfiles/miRNA.binding.potential.bed)). (Note: the fourth column should be a unique ID.)

### 1.4 Expressed microRNA list

Expressed microRNA molecules is collected by literature searching or from small RNA sequencing data analysis. Expressed microRNAs list is in plain text format (the first column is miRNA offical gene symbol and the second column is unique id in RefSeq database (i.e. [MirRNA_expr_refseq.lst](https://github.com/zhoujj2013/lncfuntk/blob/master/demo/test_data/MirRNA_expr_refseq.lst)).

### 1.5 Newly assembled long noncoding RNAs

lncFunTK can predict, prioritize, and annotate newly assembled lncRNA functions if you provide newly assembled lncRNAs coordinates in GTF format as input (i.e. [novel.final.gtf](https://github.com/zhoujj2013/lncfuntk/blob/master/demo/test_data/novel.final.gtf)). If so, the expression level of newly assembled lncRNAs must be included in the gene expression profiles.

## 2. Configure file preparation

All aforementioned input files were aranged into a configure file and lncFunTK will read in input files base on configure file. Breifly,  each parameter should seperate into Key and value by tab delimiter, lines start with "#" as comment text, which will not effect in lncFunTK analysis. The configure file must formatted as follows (i.e. [config.txt](https://github.com/zhoujj2013/lncfuntk/blob/master/demo/config.txt)):

```
# setting output dir
OUTDIR  ./

# setting output result prefix
PREFIX  mESCs

# setting species information (human or mouse)
SPE     mouse

# genome version
VERSION mm9

# lncRNA coordinates
LNCRNA  ./test_data/novel.final.gtf
# time serise transcriptome profiles(multiple datasets, place the major at first, at least 3 datasets)
EXPR    ./test_data/GeneExpressionProfiles/gene.expr.mat

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

## 3. Run lncFunTK

If the input files and configure file are well prepared, you can run lncFunTK as follows:

```
cd project_dir
# create makefile
perl lncfuntk_dir/run_lncfuntk.pl config.txt
# then make the file
make

# around 2-3 hours
# you can check the report (index.html) in 07Report.
firefox ./07Report/index.html
```

lncFunTK analysis result is placed in 07Report directory.

## 4. Explaination of result

### 4.1 LncFunTK analysis report

You can visualize LncFunTK analysis result by:

```
firefox index.html # or open in firefox browser
```


### 4.2 Co-expression network

This plain text file contains co-expression network information by co-expression analysis of expression profiles.

```
01CoExprNetwork/prefix.CoExpr.int
```

Format:

```
gene1<tab>gene2<tab>interaction_type<tab>score<tab>evidence
...
```

### 4.3 TF regulatory network

This plain text file contains TF regulatory network information by analyzing multiple TF binding profiles.

```
02TfNetwork/TfNetwork.int
```

The format is the same as Co-expression network mentioned in 4.2.

### 4.4 MicroRNA-gene regulatory network

This plain text file contains microRNA-gene interactions by analyzing Ago2 CLIP binding profile.

```
03MirnaNetwork/prefix.MirTargetGeneLevel.txt
```

The format is the same as Co-expression network.

### 4.5 Integrative gene regulatory network

Contain the integrative gene regulatory network, which created by lncFunTK.

```
07Report/GeneRegulatoryNetwork.interaction.txt
```

The format is the sample as Co-expression network.

### 4.6 Predicted functional lncRNAs and their annotation

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

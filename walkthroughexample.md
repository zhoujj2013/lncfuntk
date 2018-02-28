# Run lncFunTK analysis on your own data

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


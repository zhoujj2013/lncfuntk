# lncFunTK

lncFunTK is a toolkit that provides a novel method for integrating ChIP-seq, CLIP-seq, and RNA-seq data to predict, prioritize, and annotate lncRNA functions.

----------
## System requirements

lncFunTK runs under the Linux (i.e., Centos, see also https://www.centos.org/ for further details) on a 64-bit machine with at least 10 GB RAM. Currently, users also can submit jobs to lncFunTK server: http://sunlab.cpy.cuhk.edu.hk/lncfuntk/runlncfuntk.html.  

The python scripts used in lncFunTK are developed under Python2.7 and the Perl scripts used lncFunTK are developed under Perl v5.16.3.

lncFunTK requires python 2.7, Perl5 and several python packages listed in [python.package.requirement.txt](https://github.com/zhoujj2013/lncfuntk/blob/master/python.package.requirement.txt).;

INSTALL.pl will install these packages automatically. If you want to install them manually, please download get-pip.py from https://bootstrap.pypa.io/get-pip.py and install pip module with [instructions](https://pip.pypa.io/en/stable/installing/).

## Installation

### Get lncFunTK
```
git clone https://github.com/zhoujj2013/lncfuntk.git
```

### Installation

If you have a lncFunTK copy, run command as follow:

```
cd ./lncfuntk
perl INSTALL.pl --install
# installation finished.
```

The required packages will be automatically installed and supporting dataset for mm9 will be automatical downloaded by default. If you want supporting dataset for other genome version (mm10, hg19, hg38), you can run:

```
cd ./lncfuntk
perl INSTALL.pl --db hg19
```

### Run demo

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

LncFunTK have been tested in CentOS release 6.2, Debian 7.0 3.2.60-1+deb7u3 and ubuntu 16.04 LTS (Linux OS 64 bit).

To run lncFunTK analysis on your data, please refer to this [walkthrough example](https://github.com/zhoujj2013/lncfuntk/blob/master/walkthroughexample.md).

## lncFunTK Runtime

For lncFunTK with RNA-seq (10 samples), TF Chip-seq (10 samples), CLIP-seq (1 sample) as input, the analysis will involve ~15000 genes and speed ~3 hours with a computer node (Intel(R) Xeon(R) CPU E5-2697A v4 @ 2.60GHz, 32G RAM). 

## lncFunTK utility

### Training optimal weight values for FIS calculation

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

LR.result file stored the optimal weight values for FIS calculation. You can use the newly trained optimal weight values for lncFunTK analysis by replacing the pretrained weight value configure file (bin/Training/pretrained.weight.value.lst). 

## Please cite

1. Zhou J, Zhang S, Wang H, et al. LncFunNet: an integrated computational framework for identification of functional long noncoding RNAs in mouse skeletal muscle cells[J]. Nucleic Acids Research, 2017. PMID: [28379566](https://www.ncbi.nlm.nih.gov/pubmed/28379566).

# MAFs files preparation

This page describes the manaul steps that were performed to prepare the [example MAF files](https://github.com/umccr/MAF-summary#data-and-files) for *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*.

## Table of contents

<!-- vim-markdown-toc GFM -->
* [Data and files](#data-and-files)
* [TCGA-PAAD](#tcga-paad)
* [ICGC-AU](#icgc-au)
* [ICGC-AU (additional)](#icgc-au-additional)
* [ICGC-CA](#icgc-ca)
* [UTSW](#utsw)

<!-- vim-markdown-toc -->
<br>

## Data and files

Cohort | Samples no. | NCBI Build | File name
------------ | ------------ | ------------ | ------------
<img src="img/flag-of-United-States-of-America.png" width="10%"> &nbsp;&nbsp; TCGA PAAD | 143 | 37 | PAAD.tcga.uuid.curated.somatic.maf
<img src="img/flag-of-Australia.png" width="10%"> &nbsp;&nbsp; ICGC PACA-AU | 395 | 37 | PACA-AU.icgc.simple_somatic_mutation.maf
<img src="img/flag-of-Australia.png" width="10%"> &nbsp;&nbsp; ICGC PACA-AU (additional) | 25 | 37 | DCC17_PDAC_Not_in_DCC.maf
<img src="img/flag-of-Canada.png" width="10%"> &nbsp;&nbsp; ICGC PACA-CA | 336 | 37 | PACA-CA.icgc.simple_somatic_mutation.maf
<img src="img/flag-of-United-States-of-America.png" width="10%"> &nbsp;&nbsp; UTSW ([PMID: 25855536](https://www.ncbi.nlm.nih.gov/pubmed/25855536)) | 109 | 37 | To be generated
<br />

### TCGA-PAAD

Original file name | Modified file name
------------ | ------------
*PACA*.tcga.uuid.curated.somatic.maf | *PAAD*.tcga.uuid.curated.somatic.maf
<br/>

**Comments**:

Removed the two header lines (starting with '#') from the original MAF file. One sample (*TCGA-IB-7651-01A-11D-2154-08*) seems to have extremely high mutation burden. Removed this sample and created cleaned maf file 

```
grep -v 'TCGA-IB-7651-01A-11D-2154-08' <PAAD.tcga.uuid.curated.somatic.maf >PAAD.tcga.uuid.curated.somatic.clean.maf
```

<br>

### ICGC-AU

Original file name | Modified file name
------------ | ------------
simple_somatic_mutation.open.tsv | PACA-AU.icgc.simple_somatic_mutation.maf
<br/>

**Comments**:

Extracted rows for ICGA-AU

```
egrep PACA-AU simple_somatic_mutation.open.tsv > PACA-AU.icgc.simple_somatic_mutation.tsv
```

...added the header

```
head -1 simple_somatic_mutation.open.tsv > header.txt
echo -e '0r header.txt\nw' | ed PACA-AU.icgc.simple_somatic_mutation.tsv
```

...and then converted to MAF file using *[icgcMutationToMAF.R](https://github.com/umccr/MAF-summary/tree/master/icgcMutationToMAF.R)* script

```
Rscript icgcMutationToMAF.R --icgc_file PACA-AU.icgc.simple_somatic_mutation.tsv --output PACA-AU.icgc.simple_somatic_mutation.maf
```

<br/>

### ICGC-AU (additional)

Original file name | Modified file name
------------ | ------------
DCC17_PDAC_Not_in_DCC_maf.xlsx | DCC17_PDAC_Not_in_DCC.maf
<br/>

**Comments**:

Changed the *Matched_Tumour_Sample_Barcode* to *Tumor_Sample_Barcode* to be compatible with R *maftools*

<br/>

### ICGC-CA

Original file name | Modified file name
------------ | ------------
simple_somatic_mutation.open.tsv | PACA-CA.icgc.simple_somatic_mutation.maf
<br/>

**Comments**:

Extracted rows for ICGA-CA

```
egrep PACA-CA simple_somatic_mutation.open.tsv > PACA-CA.icgc.simple_somatic_mutation.tsv
```
 
...added the header

```
head -1 simple_somatic_mutation.open.tsv > header.txt
echo -e '0r header.txt\nw' | ed PACA-CA.icgc.simple_somatic_mutation.tsv
```

...and then converted to MAF file using *[icgcMutationToMAF.R](https://github.com/umccr/MAF-summary/tree/master/icgcMutationToMAF.R)* script

```
Rscript icgcMutationToMAF.R --icgc_file PACA-CA.icgc.simple_somatic_mutation.tsv --output PACA-CA.icgc.simple_somatic_mutation.maf
```

<br/>

### UTSW

Original file name | Modified file name
------------ | ------------
UTSW-MAF.xlsx | To be generated
<br/>

**Comments**:

WXS data to re-analyse, since only coding mutations were reported (no silent mutations).

<br />
<br />
## TCGA PAAD cohort MAF summary

Example of *[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/summariseMAFs.R)* output files for TCGA PAAD ( <img src="../Figures/flag-of-United-States-of-America.png" width="2.5%"> ) cohort. This example show one sample (***TCGA-IB-7651-01A-11D-2154-08***) with extremely high mutation burden.


## Table of contents

<!-- vim-markdown-toc GFM -->
* [Output before and after removing problematic sample](#output-before-and-after-removing-problematic-sample)
  * [Variants per sample plot and oncoplot](#variants-per-sample-plot-and-oncoplot)
  * [MAF summary](#maf-summary)
  * [Sample summary](#sample-summary)
  * [Gene summary](#gene-summary)
  * [MAF fields](#maf-fields-table)
  * [Transitions and transversions summary](#transitions_and_transversionse-summary)
    * [Fraction tab](#fraction-tab)
    * [Count tab](#count-tab)
    * [TiTv tab](#titv-tab)


<!-- vim-markdown-toc -->
<br>

## Output before and after removing problematic sample

### Variants per sample plot and oncoplot

<br />

Solarized dark             |  Solarized Ocean
:-------------------------:|:-------------------------:
![](https://github.com/umccr/MAF-summary/tree/master/TCGA_PAAD_MAF_summary/Figures/MAF_summary_TCGA-PAAD.jpg)  |  ![](https://github.com/umccr/MAF-summary/tree/master/TCGA_PAAD_MAF_summary/Figures/Oncoplot_TCGA-PAAD.jpg)

<img src="Figures/MAF_summary_TCGA-PAAD.jpg" width="30%"> <img src="Figures/Oncoplot_TCGA-PAAD.jpg" width="40%">

>A summary for MAF file displaying frequency of various mutation/SNV types/classes (top panel), the number of variants in each sample as a stacked bar-plot (bottom-left) and variant types as a box-plot (bottom-middle), as well as the frequency of different mutation types for the top 10 mutated genes (bottom-right). The horizontal dashed line in stacked bar-plot represents median number of variants across the cohort.


>Oncoplot illustrating different types of mutations observed across samples for the 10 most frequently mutated genes. The side and top bar-plots present the frequency of mutations in each gene and in each sample, respectively.

<br />


---
### Sample summary

[MAF_sample_summary.xlsx](https://github.com/umccr/MAF-summary/tree/master/ICGC_PACA-CA_MAF_summary/MAF_sample_summary.xlsx) - tab ***ICGC-PACA-CA***

>Excel spreadsheet tab with per-sample information (rows) about no. of different types of mutations (columns), including frameshift deletions, frameshift insertions, in-frame deletions, in-frame insertions, missense mutations, nonsense mutations, nonstop mutations, splice site mutations, translation start site mutations, as well as the total no. of mutations present in the MAF file.

<br />


<br />

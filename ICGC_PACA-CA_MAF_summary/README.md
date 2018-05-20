# MAF-summary

Set of scripts to summarise, analyse and visualise multiple [Mutation Annotation Format](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) (MAF) files using *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* R package. The maftools manuscript is on [bioRxiv](http://dx.doi.org/10.1101/052662) and scripts are available on [GitHub](https://github.com/PoisonAlien/maftools).


## Table of contents

<!-- vim-markdown-toc GFM -->
* [MAF field requirements](#maf-field-requirements)
* [Data and files](#data-and-files)
* [Scripts](#scripts)
* [Converting ICGC mutation format to MAF](#converting-icgc-mutation-format-to-maf)
* [Summarising and visualising multiple MAF files](#summarising-and-visualising-multiple-maf-files)
  * [Example plots](#example-plots)

<!-- vim-markdown-toc -->
<br>


#### Example plots

<br />
<img src="Figures/MAF_summary_ICGC-PACA-CA.jpg" width="50%">

>A summary for MAF file from the ICGC PACA-CA cohort. It displays frequency of various mutation types/classes (top panel), the number of variants in each sample as a stacked bar-plot (bottom-left) and variant types as a box-plot (bottom-middle), as well as the frequency of different mutation types for the top 10 mutated genes (bottom-right). The horizontal dashed line in stacked bar-plot represents median number of variants across the cohort.

<br />
<br />

<img src="Figures/Oncoplot_ICGC-PACA-CA.jpg" width="50%">

>Oncoplot illustrating illustrating different types of mutations observed across ICGC PACA-CA samples for the 10 most frequently mutated genes. The side and top bar-plots present the frequency of mutations in each gene and in each sample, respectively.

<br />
<br />


<img src="Figures/Transition_and_transversions_ICGC-PACA-CA.jpg" width="50%">

> Plots presenting the transition and transversions distribution in ICGC PACA-CA cohort. The box-plots (top panel) show the overall distribution of the six different conversions (left), and the transition and transversions frequency (right). The stacked bar-plot displays the fraction of the six different conversions in each sample.

<br />
<br />


<img src="Figures/Compare_against_TCGA_cohorts_ICGC-PACA-CA.jpg" width="50%">

>Plot illustrating the mutation load in ICGC PACA-CA cohort along distribution of variants compiled from over 10,000 WXS samples across 33 TCGA landmark cohorts. Every dot represents a sample whereas the red horizontal lines are the median numbers of mutations in the respective cancer types. The vertical axis (log scaled) shows the number of mutations per megabase whereas the different cancer types are ordered on the horizontal axis based on their median numbers of somatic mutations. This plot is similar to the one described in the paper [Signatures of mutational processes in human cancer](https://www.ncbi.nlm.nih.gov/pubmed/23945592) by Alexandrov *et al*.

<br />
<br />

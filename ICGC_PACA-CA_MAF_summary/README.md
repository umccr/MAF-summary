# ICGC PACA-CA cohort MAF summary

Example of *[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/summariseMAFs.R)* output files for ICGC PACA-CA <img src="/../Figures/flag-of-United-States-of-America.png" width="10%">) cohort.


## Table of contents

<!-- vim-markdown-toc GFM -->
* [MAF summary plot](#maf-summary-plot)
* [Data and files](#data-and-files)
* [Scripts](#scripts)
* [Converting ICGC mutation format to MAF](#converting-icgc-mutation-format-to-maf)
* [Summarising and visualising multiple MAF files](#summarising-and-visualising-multiple-maf-files)
  * [Example plots](#example-plots)

<!-- vim-markdown-toc -->
<br>


#### MAF summary plot

<br />
<img src="Figures/MAF_summary_ICGC-PACA-CA.jpg" width="50%">

>A summary for MAF file displaying frequency of various mutation types/classes (top panel), the number of variants in each sample as a stacked bar-plot (bottom-left) and variant types as a box-plot (bottom-middle), as well as the frequency of different mutation types for the top 10 mutated genes (bottom-right). The horizontal dashed line in stacked bar-plot represents median number of variants across the cohort.

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

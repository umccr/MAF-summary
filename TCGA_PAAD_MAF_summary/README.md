## TCGA PAAD cohort MAF summary

Example of *[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/summariseMAFs.R)* output files for TCGA PAAD ( <img src="../Figures/flag-of-United-States-of-America.png" width="2.5%"> ) cohort. This example shows one sample with extremely high mutation burden. The *[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/summariseMAFs.R)* script was re-ran after removing the problematic sample and the outputs were compared.


#### MAF summary plots for all TCGA PAAD samples

<br />

<img src="Figures/MAF_summary_TCGA-PAAD.jpg" width="45%"> &nbsp;&nbsp;&nbsp; <img src="Figures/Oncoplot_TCGA-PAAD.jpg" width="45%">

<br /><br />

####  ...and after removing problematic sample

<img src="Figures/MAF_summary_TCGA-PAAD_clean.jpg" width="45%"> &nbsp;&nbsp;&nbsp; <img src="Figures/Oncoplot_TCGA-PAAD_clean.jpg" width="45%">

>The variants per sample plot and oncoplot within the *[MAF_summary_TCGA-PAAD.pdf](https://github.com/umccr/MAF-summary/tree/master/TCGA_PAAD_MAF_summary/MAF_summary_TCGA-PAAD.pdf)* file indicates that one sample (***TCGA-IB-7651-01A-11D-2154-08***) has extremely high mutation burden compared to other samples within this cohort (the stacked bar-plots in the top panel). After removing this sample from the MAF file the variants distribution is more uniform across remaining samples (bottom panel). For plots description see [MAF summary plot](https://github.com/umccr/MAF-summary/tree/master/ICGC_PACA-CA_MAF_summary#maf-summary-plot) and [Oncoplot](https://github.com/umccr/MAF-summary/tree/master/ICGC_PACA-CA_MAF_summary#oncoplot) sections.


<br />


---
### Sample summary

[MAF_sample_summary.xlsx](https://github.com/umccr/MAF-summary/tree/master/ICGC_PACA-CA_MAF_summary/MAF_sample_summary.xlsx) - tab ***ICGC-PACA-CA***

>Excel spreadsheet tab with per-sample information (rows) about no. of different types of mutations (columns), including frameshift deletions, frameshift insertions, in-frame deletions, in-frame insertions, missense mutations, nonsense mutations, nonstop mutations, splice site mutations, translation start site mutations, as well as the total no. of mutations present in the MAF file.

<br />


<br />

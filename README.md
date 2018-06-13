# MAF-summary

Set of scripts to summarise, analyse and visualise multiple [Mutation Annotation Format](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) (MAF) files using *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* R package. The maftools manuscript is on [bioRxiv](http://dx.doi.org/10.1101/052662) and scripts are available on [GitHub](https://github.com/PoisonAlien/maftools).


## Table of contents

<!-- vim-markdown-toc GFM -->
* [MAF field requirements](#maf-field-requirements)
* [Scripts](#scripts)
* [Converting ICGC mutation format to MAF](#converting-icgc-mutation-format-to-maf)
* [Summarising and visualising multiple MAF files](#summarising-and-visualising-multiple-maf-files)
  * [Example output](#example-output)
    * [ICGC PACA-CA cohort](https://github.com/umccr/MAF-summary/blob/master/examples/ICGC_PACA-CA_MAF_summary)
    * [TCGA PAAD cohort](https://github.com/umccr/MAF-summary/blob/master/examples/TCGA_PAAD_MAF_summary)
    * [HTML report](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFs.html)

<!-- vim-markdown-toc -->
<br>

## MAF field requirements

While MAF files contain many fields ranging from chromosome names to cosmic annotations, the mandatory fields used by maftools are the following:

Field | Description | Allowed values
------------ | ------------ | ------------
Hugo_Symbol | [HUGO](https://www.genenames.org/) gene symbol | -
Chromosome | Chromosome no. | 1-22, X, Y
Start_Position | Event start position | Numeric
End_Position | Event end position | Numeric
Reference_Allele | Positive strand reference allele | A, T, C, G
Tumor_Seq_Allele2 | Primary data genotype | A, T, C, G
Variant_Classification | Translational effect of variant allele | Frame_Shift_Del, Frame_Shift_Ins, In_Frame_Del, In_Frame_Ins, Missense_Mutation, Nonsense_Mutation, Silent, Splice_Site, Translation_Start_Site, Nonstop_Mutation, 3'UTR, 3'Flank, 5'UTR, 5'Flank, IGR, Intron, RNA, Targeted_Region, De_novo_Start_InFrame, De_novo_Start_OutOfFrame, Splice_Region, Unknown
Variant_Type | Variant Type | SNP, DNP, INS, DEL, TNP and ONP
Tumor_Sample_Barcode | Sample ID | Either a TCGA barcode, or for non-TCGA data, a literal SAMPLE_ID as listed in the clinical data file
<br />

## Scripts

Script | Description | Packages
------------ | ------------ | ------------
*[icgcMutationToMAF.R](https://github.com/umccr/MAF-summary/tree/master/scripts/icgcMutationToMAF.R)* | Converts ICGC [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) file to [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file | *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*
*[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFs.R)* | Summarises and visualises multiple [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) files | *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* <br> *[xlsx](https://cran.r-project.org/web/packages/xlsx/xlsx.pdf)*
<br />


## Converting ICGC mutation format to MAF

The publicly available ICGC mutation data is stored in [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) file, which is similar to MAF format in its structure, but the field names and classification of variants are different. The *[icgcMutationToMAF.R](https://github.com/umccr/MAF-summary/tree/master/scripts/icgcMutationToMAF.R)* script implements *icgcSimpleMutationToMAF* function within *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* R package to convert ICGC [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) to MAF.


**Script**: *[icgcMutationToMAF.R](https://github.com/umccr/MAF-summary/tree/master/scripts/icgcMutationToMAF.R)*

Argument | Description
------------ | ------------
--icgc_file | ICGC Simple Somatic Mutation Format file to be converted
--output | Output file name
<br />

**Command line use example**:

```
Rscript icgcMutationToMAF.R --icgc_file PACA-AU.icgc.simple_somatic_mutation.tsv --output PACA-AU.icgc.simple_somatic_mutation.maf
```
<br>


>This will convert the ***../data/PACA-AU.icgc.simple_somatic_mutation.tsv*** [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) file into [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) as output it as ***../data/PACA-AU.icgc.simple_somatic_mutation.maf***.

<br>

## Summarising and visualising multiple MAF files

To summarise multiple MAF files run the *[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFs.R)* script. This script catches the arguments from the command line and passes them to the *[summariseMAFs.Rmd](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFs.Rmd)* script to produce the html report, generate set of plots and excel spreadsheets summarising each MAF file.

**Script**: *[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFs.R)*

Argument | Description
------------ | ------------
--maf_dir | Directory with *MAF* files
--maf_files | List of *MAF* files to be processed. Each file name is expected to be separated by comma
--cohorts | Desired names of each cohort. The names are expected to be in the same order as provided *MAF* files
--out_dir | Output directory
<br />

**Command line use example**:

```
Rscript summariseMAFs.R --maf_dir /data --maf_files PACA-AU.icgc.simple_somatic_mutation.maf,PACA-CA.icgc.simple_somatic_mutation.maf --cohorts ICGC-PACA-AU,ICGC-PACA-CA --out_dir MAF_summary
```
<br>

This will generate *[summariseMAFs.html](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFs.html)* and *[summariseMAFs.md](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFs.md)* reports with interactive summary tables and heatmaps. It will also create a folder with user-defined name with the following output tables and plots:

Output file | Component | Description
------------ | ------------| -----------
MAF_summary.xlsx | - | Excel spreadsheet with basic information about each MAF file (NCBI build, no. fo samples and genes, no. of different mutation types) presented in a separate tab
MAF_sample_summary.xlsx | - | Excel spreadsheet with per-sample information about no. of different types of mutations. The summary is provided for each cohort in a separate tab
MAF_gene_summary.xlsx | - | Excel spreadsheet with per-gene information about no. of different types of mutations, as well as mutated samples. The summary is provided for each cohort in a separate tab
MAF_fields.xlsx | - | Excel spreadsheet listing all fields (columns) in each MAF file presented in a separate tab
MAF_sample_summary_heatmap_ [***cohort***] .html | - | Samples summary in a form of interactive heatmap facilitating outliers detection
MAF_agene_summary_heatmap_ [***cohort***] .html | - | Genes summary in a form of interactive heatmap (displays the top 50 mutated genes)
MAF_summary_titv.xlsx | [***cohort***] (fraction) | Excel tab containing information about the fraction of each of the six different conversions (C>A, C>G, C>T, T>C, T>A and T>G) in each sample. The information for each cohort is provided in a separate tab
MAF_summary_titv.xlsx | [***cohort***] (count) | Excel tab containing information about the count of each of the six different conversions (C>A, C>G, C>T, T>C, T>A and T>G) in each sample. The information for each cohort is provided in a  separate tab
MAF_summary_titv.xlsx | [***cohort***] (TiTv) | Excel tab containing information the fraction of transitions and transversions in each sample. The information for each cohort is provided in a separate tab
MAF_summary_[***cohort***].pdf | MAF summary | Displays no. of variants in each sample as a stacked bar-plot and variant types as a box-plot summarised by *Variant_Classification* field
... | Oncoplot | A heatmap-like plot illustrating different types of mutations observed across all samples for the 10 most frequently mutated genes. The side and top bar-plots present the frequency of mutations in each gene and in each sample, respectively
... | Transition and transversions | Contains a box-plot showing overall distribution of six different conversions and a stacked bar-plot showing fraction of conversions in each sample
... | Comparison with TCGA cohorts | Displays the observed mutation load of queried cohort along distribution of variants compiled from over 10,000 WXS samples across 33 TCGA landmark cohorts
<br />


### Example output

Some example MAF files are located on [Spartan](https://dashboard.hpc.unimelb.edu.au/) cluster and are described in [Pancreatic-data-harmonization](https://github.com/umccr/Pancreatic-data-harmonization) repository.<br>

* [ICGC PACA-CA cohort](https://github.com/umccr/MAF-summary/blob/master/examples/ICGC_PACA-CA_MAF_summary) &nbsp; ( <img src="img/flag-of-Canada.png" width="2.5%"> ) - includes descrition for output tables and plots
* [TCGA PAAD cohort](https://github.com/umccr/MAF-summary/blob/master/examples/TCGA_PAAD_MAF_summary) &nbsp; ( <img src="img/flag-of-United-States-of-America.png" width="2.5%"> ) - highlihts sample demonstrating extremely high mutation burden
* [HTML report](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFs.html) - R html report for all cohorts


<br />
<br />

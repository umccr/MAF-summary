# MAF-summary - output files description



## Table of contents

<!-- vim-markdown-toc GFM -->
* [Summarising and visualising MAF file(s)](#summarising-and-visualising-maf-files)
* [Summarising and visualising MAF file(s) for selected genes](#summarising-and-visualising-maf-files-for-selected-genes)

<!-- vim-markdown-toc -->
<br>

## Summarising and visualising MAF file(s)

**Script**: *[summariseMAFs.R](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFs.R)*

Along with the *[summariseMAFs.html](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFs.html)* and *[summariseMAFs.md](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFs.md)* reports, described [here](README.md#summarising-and-visualising-multiple-maf-files), the script also generates a folder with user-defined name with tables and plots described below:

Output file | Component | Description
------------ | ------------| -----------
MAF_summary.xlsx | - | Excel spreadsheet with basic information about each MAF file (NCBI build, no. fo samples and genes, no. of different mutation types) presented in a separate tab
MAF_sample_summary.xlsx | - | Excel spreadsheet with per-sample information about no. of different types of mutations. The summary is provided for each cohort in a separate tab
MAF_gene_summary.xlsx | - | Excel spreadsheet with per-gene information about no. of different types of mutations, as well as mutated samples. The summary is provided for each cohort in a separate tab
MAF_fields.xlsx | - | Excel spreadsheet listing all fields (columns) in each MAF file presented in a separate tab
MAF_sample_summary_heatmap_[***cohort***].html | - | Samples summary in a form of interactive heatmap facilitating outliers detection
MAF_agene_summary_heatmap_[***cohort***].html | - | Genes summary in a form of interactive heatmap (displays the top 50 mutated genes)
MAF_summary_titv.xlsx | [***cohort***] (fraction) | Excel tab containing information about the fraction of each of the six different conversions (C>A, C>G, C>T, T>C, T>A and T>G) in each sample. The information for each cohort is provided in a separate tab
MAF_summary_titv.xlsx | [***cohort***] (count) | Excel tab containing information about the count of each of the six different conversions (C>A, C>G, C>T, T>C, T>A and T>G) in each sample. The information for each cohort is provided in a  separate tab
MAF_summary_titv.xlsx | [***cohort***] (TiTv) | Excel tab containing information the fraction of transitions and transversions in each sample. The information for each cohort is provided in a separate tab
MAF_summary_[***cohort***].pdf | MAF summary | Displays no. of variants in each sample as a stacked bar-plot and variant types as a box-plot summarised by *Variant_Classification* field
... | Oncoplot | A heatmap-like plot illustrating different types of mutations observed across all samples for the 10 most frequently mutated genes. The side and top bar-plots present the frequency of mutations in each gene and in each sample, respectively
... | Transition and transversions | Contains a box-plot showing overall distribution of six different conversions and a stacked bar-plot showing fraction of conversions in each sample
... | Comparison with TCGA cohorts | Displays the observed mutation load of queried cohort along distribution of variants compiled from over 10,000 WXS samples across 33 TCGA landmark cohorts
<br />


## Summarising and visualising MAF file(s) for selected genes

**Script**: *[summariseMAFsGenes.R](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFsGenes.R)*

Along with the *[summariseMAFsGenes.html](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFsGenes.html)* and *[summariseMAFsGenes.md](https://github.com/umccr/MAF-summary/tree/master/scripts/summariseMAFsGenes.md)* reports, described [here](README.md#summarising-and-visualising-multiple-maf-files-for-selected-genes), the script also generates a folder with user-defined name with the following output tables and plots:

Output file | Component | Description
------------ | ------------| -----------
MAF_gene_summary.xlsx | - | Excel spreadsheet with per-gene information about no. of different types of mutations, as well as mutated samples. The summary is provided for each cohort in a separate tab
MAF_somatic_interactions.xlsx | [***cohort***] (gene pairs) | Excel spreadsheet with results from pair-wise *Fisher’s Exact* test for detection mutually exclusive or co-occurring genes. The summary is provided for each cohort in a separate tab
MAF_somatic_interactions.xlsx | [***cohort***] (gene sets) | Excel spreadsheet with results from *cometExactTest* for identification of potentially altered gene sets involving > 2 two genes (more details [here](https://www.ncbi.nlm.nih.gov/pubmed/26253137)). The summary is provided for each cohort in a separate tab
MAF_gene_summary_heatmap_[***cohort***].html | - | Genes summary in a form of interactive heatmap (displays the user-defined genes)
MAF_pair-wise_comparisons_heatmap.html | - | Interactive heatmap with colours indicating the adjusted *Fisher Exact* test p-values for all genes in pair-wise comprisons between queried *MAFs* to aid identification of global differences in mutation patterns between corresponding cohorts
MAF_summary_genes_[***cohort***].pdf | Oncoplots | A heatmap-like plots illustrating different types of mutations observed across all samples for the selected genes. The side and top bar-plots present the frequency of mutations in each gene and in each sample, respectively
MAF_summary_genes_[***cohort***].pdf | Somatic interactions plots | Pair-wise heatmaps with colurs indicating the pair-wise *Fisher’s Exact* test p-values to faclilitate detection of mutually exclusive or co-occurring genes.
<br />

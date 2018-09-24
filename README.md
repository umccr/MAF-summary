# MAF-summary

Set of scripts to summarise, analyse and visualise [Mutation Annotation Format](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) (MAF) file(s) using *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* R package. The maftools manuscript is on [bioRxiv](http://dx.doi.org/10.1101/052662) and scripts are available on [GitHub](https://github.com/PoisonAlien/maftools).


## Table of contents

<!-- vim-markdown-toc GFM -->
* [MAF field requirements](#maf-field-requirements)
* [Scripts summary](#scripts-summary)
* [Converting VCF files to MAF files](#converting-vcf-files-to-maf-files)
* [Converting ICGC mutation format to MAF](#converting-icgc-mutation-format-to-maf)
* [Summarising and visualising MAF file(s)](#summarising-and-visualising-maf-files)
  * [Example output](#example-output)
* [Summarising and visualising MAF file(s) for selected genes](#summarising-and-visualising-maf-files-for-selected-genes)
  * [Example output](#example-output)
* [Pipeline for processing in-house data](#pipeline-for-processing-in-house-data)

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

## Scripts summary

Script | Description
------------ | ------------
*[multi_vcf2maf.pl](./scripts/multi_vcf2maf.pl)* | Converts multiple [VCF](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) (Variant Call Format) file to [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file 
*[icgcMutationToMAF.R](./scripts/icgcMutationToMAF.R)* | Converts ICGC [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) file to [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file 
*[summariseMAFs.R](./scripts/summariseMAFs.R)* | Summarises and visualises [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file(s)
*[summariseMAFsGenes.R](./scripts/summariseMAFsGenes.R)* | Summarises and visualises [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file(s) for selected genes
<br />

## Converting VCF files to MAF files

To convert multiple VCF files into one collective MAF file use *[multi_vcf2maf.pl](./multi_vcf2maf.pl)* script. It requires a file with listed [VCF](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) files to be converted into corresponding MAF files (see an example [here](./examples/example_vcf_list.txt)). The individual MAF files are then merged into one collective MAF file, which is saved in the same directory as the files listing VCF files.


**Script**: *[multi_vcf2maf.pl](./multi_vcf2maf.pl)*


Argument | Description
------------ | ------------
--vcf_list | Full path with name of a file listing VCF files to be converted
--v2m | Full path to [vcf2maf.pl](https://github.com/mskcc/vcf2maf) script
--ref | Reference FASTA file
--maf_file | Name of the merged MAF file to be created
<br />

**Command line use example**:

```
perl multi_vcf2maf.pl  -l /examples/example_vcf_list.txt  -s /tools/vcf2maf.pl  -r /reference/GRCh37-lite.fa  -m /data/example.maf
```
<br>


>This will convert the [VCF](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) files listed in [example_vcf_list.txt](./examples/example_vcf_list.txt) into corresponding MAF files, which are then will be merged into one collective MAF file **example.maf** saved in **data** directory.

<br>


## Converting ICGC mutation format to MAF

The publicly available ICGC mutation data is stored in [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) file, which is similar to MAF format in its structure, but the field names and classification of variants are different. The *[icgcMutationToMAF.R](./scripts/icgcMutationToMAF.R)* script implements *icgcSimpleMutationToMAF* function within *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* R package to convert ICGC [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) to MAF.


**Script**: *[icgcMutationToMAF.R](./scripts/icgcMutationToMAF.R)*

Argument | Description
------------ | ------------
--icgc_file | ICGC Simple Somatic Mutation Format file to be converted
--output | Output file name
<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*

**Command line use example**:

```
Rscript icgcMutationToMAF.R --icgc_file PACA-AU.icgc.simple_somatic_mutation.tsv --output PACA-AU.icgc.simple_somatic_mutation.maf
```
<br>


>This will convert the ***../data/PACA-AU.icgc.simple_somatic_mutation.tsv*** [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) file into [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) as output it as ***../data/PACA-AU.icgc.simple_somatic_mutation.maf***.

<br>

## Summarising and visualising MAF file(s)

To summarise MAF file(s) run the *[summariseMAFs.R](./scripts/summariseMAFs.R)* script. This script catches the arguments from the command line and passes them to the *[summariseMAFs.Rmd](./scripts/summariseMAFs.Rmd)* script to produce the html report, generate set of plots and excel spreadsheets summarising each MAF file.

NOTE: Only non-synonymous variants with high/moderate variant consequences, including *frame shift deletions*, *frame shift deletions*, *splice site mutations*, *translation start site mutations* ,*nonsense mutation*, *nonstop mutations*, *in-frame deletion*, *in-frame insertions* and *missense mutation*, are reported (silent variants are ignored).

**Script**: *[summariseMAFs.R](./scripts/summariseMAFs.R)*

Argument | Description
------------ | ------------
--maf_dir | Directory with *MAF* file(s)
--maf_files | List of *MAF* file(s) to be processed. Each file name is expected to be separated by comma
--datasets | Desired names of each dataset. The names are expected to be in the same order as provided *MAF* files
--out_dir | Output directory
<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[openxlsx](https://cran.r-project.org/web/packages/openxlsx/openxlsx.pdf)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*, *[knitr](https://cran.r-project.org/web/packages/knitr/knitr.pdf)*, *[DT](https://rstudio.github.io/DT/)*, *[plotly](https://plot.ly/r/)*, *[heatmaply](https://cran.r-project.org/web/packages/heatmaply/vignettes/heatmaply.html)*, *[ggplot2](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf)*

**Command line use example**:

```
Rscript summariseMAFs.R --maf_dir /data --maf_files PACA-AU.icgc.simple_somatic_mutation.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --out_dir MAF_summary
```
<br>

This will generate *[summariseMAFs.html](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFs.html)* and *[summariseMAFs.md](./scripts/summariseMAFs.md)* reports with interactive summary tables and heatmaps. It will also create a folder with user-defined name containing output tables and plots described [here](README_output_files.md).

### Example output

Some example MAF files are located on [Spartan](https://dashboard.hpc.unimelb.edu.au/) cluster and are described in [Pancreatic-data-harmonization](https://github.com/umccr/Pancreatic-data-harmonization) repository.<br>

* [ICGC PACA-CA dataset](https://github.com/umccr/MAF-summary/blob/master/examples/ICGC_PACA-CA_MAF_summary) &nbsp; ( <img src="img/flag-of-Canada.png" width="2.5%"> ) - includes descrition for output tables and plots
* [TCGA PAAD dataset](https://github.com/umccr/MAF-summary/blob/master/examples/TCGA_PAAD_MAF_summary) &nbsp; ( <img src="img/flag-of-United-States-of-America.png" width="2.5%"> ) - highlihts sample demonstrating extremely high mutation burden
* [HTML report](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFs.html) - R html report for all datasets

<br />

## Summarising and visualising MAF file(s) for selected genes

To summarise MAF file(s) for specific set of genes run the *[summariseMAFsGenes.R](./scripts/summariseMAFsGenes.R)* script. This script catches the arguments from the command line and passes them to the *[summariseMAFsGenes.Rmd](./scripts/summariseMAFsGenes.Rmd)* script to produce the html report, generate set of plots and excel spreadsheets summarising user-defined genes for individual MAF files.

NOTE: Only non-synonymous variants with high/moderate variant consequences, including *frame shift deletions*, *frame shift deletions*, *splice site mutations*, *translation start site mutations* ,*nonsense mutation*, *nonstop mutations*, *in-frame deletion*, *in-frame insertions* and *missense mutation*, are reported (silent variants are ignored).

**Script**: *[summariseMAFsGenes.R](./scripts/summariseMAFsGenes.R)*

Argument | Description
------------ | ------------
--maf_dir | Directory with *MAF* file(s)
--maf_files | List of *MAF* file(s) to be processed. Each file name is expected to be separated by comma
--datasets | Desired names of each dataset. The names are expected to be in the same order as provided *MAF* files
--genes | Genes to query in each *MAF* file
--out_dir | Output directory
<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[openxlsx](https://cran.r-project.org/web/packages/openxlsx/openxlsx.pdf)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*, *[knitr](https://cran.r-project.org/web/packages/knitr/knitr.pdf)*, *[DT](https://rstudio.github.io/DT/)*, *[plotly](https://plot.ly/r/)*, *[heatmaply](https://cran.r-project.org/web/packages/heatmaply/vignettes/heatmaply.html)*, *[ggplot2](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf)*

**Command line use example**:

```
Rscript summariseMAFsGenes.R --maf_dir /data --maf_files PACA-AU.icgc.simple_somatic_mutation.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes KRAS,SMAD4,TP53,CDKN2A,ARID1A,BRCA1,BRCA2 --out_dir MAF_summary
```
<br>

This will generate *[summariseMAFsGenes.html](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFsGenes.html)* and *[summariseMAFsGenes.md](./scripts/summariseMAFsGenes.md)* reports with interactive summary tables and heatmaps. It will also create a folder with user-defined name containing output tables and plots described [here](README_output_files.md).

### Example output

Some example MAF files are located on [Spartan](https://dashboard.hpc.unimelb.edu.au/) cluster and are described in [Pancreatic-data-harmonization](https://github.com/umccr/Pancreatic-data-harmonization) repository.<br>

* [HTML report](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFsGenes.html) - R html report for all datasets


### Pipeline for processing in-house data

... to be completed



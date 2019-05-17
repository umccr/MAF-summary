# MAF-summary

Set of scripts to **summarise**, **analyse** and **visualise** [Mutation Annotation Format](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) (MAF) file(s) using *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* R package. The maftools manuscript is on [bioRxiv](http://dx.doi.org/10.1101/052662) and scripts are available on [GitHub](https://github.com/PoisonAlien/maftools). The downstream analyses include **selection analyses** and **cancer driver discovery**.


## Table of contents

<!-- vim-markdown-toc GFM -->
* [MAF field requirements](#maf-field-requirements)
* [Scripts summary](#scripts-summary)
* [Converting VCF files to MAF files](#converting-vcf-files-to-maf-files)
* [Converting ICGC mutation format to MAF](#converting-icgc-mutation-format-to-maf)
* [Extracting variants within exonic regions](#extracting-variants-within-exonic-regions)
* [Changing sample names](#changing-sample-names)
* [Subsetting MAF](#subsetting-maf)
* [Merging MAFs](#merging-mafs)
* [Summarising and visualising MAF file(s)](#summarising-and-visualising-maf-files)
  * [Example output](#example-output)
* [Summarising and visualising MAF file(s) for selected genes](#summarising-and-visualising-maf-files-for-selected-genes)
  * [Example output](#example-output)

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
*[exons_maf.pl](./scripts/exons_maf.pl)* | Extracts variants detected within exonic regions
*[MAFsamplesRename.R](./scripts/MAFsamplesRename.R)* | Changes sample names in [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field
*[subsetMAF.R](./scripts/subsetMAF.R)* | Subsets MAF based on defined list of samples and/or genes
*[mergeMAFs.R](./scripts/mergeMAFs.R)* | Merges multiple MAFs
*[summariseMAFs.R](./scripts/summariseMAFs.R)* | Summarises and visualises [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file(s)
*[summariseMAFsGenes.R](./scripts/summariseMAFsGenes.R)* | Summarises and visualises [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file(s) for selected genes

<br />

## Converting VCF files to MAF files

To convert multiple VCF files into one collective MAF file use *[multi_vcf2maf.pl](./scripts/multi_vcf2maf.pl)* script. It requires a file with listed [VCF](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) files to be converted into corresponding MAF files (see an example [here](./examples/example_vcf_list.txt)). The individual MAF files are then merged into one collective MAF file, which is saved in the same directory as the files listing VCF files.


**Script**: *[multi_vcf2maf.pl](./scripts/multi_vcf2maf.pl)*


Argument | Description
------------ | ------------
--vcf_list | Full path with name of a file listing VCF files to be converted
--exons | Include exonic regions only: TRUE/T or FALSE/F (defualt)
--v2m | Full path to [vcf2maf.pl](https://github.com/mskcc/vcf2maf) script
--ref | Reference FASTA file
--maf_file | Name of the merged MAF file to be created

<br />


NOTE: *Samtools* and *tabix* are required to run this script. These can be loaded on [Spartan](https://dashboard.hpc.unimelb.edu.au/) with *module load* commnand:

```
module load SAMtools/1.9-intel-2018.u4

module load tabix/0.2.6-intel-2017.u2
```

**Command line use example**:

```
perl multi_vcf2maf.pl  -l /examples/example_vcf_list.txt  -e FALSE  -s /tools/vcf2maf.pl  -r /reference/GRCh37-lite.fa  -m example.maf
```

<br>

>This will convert the [VCF](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) files listed in [example_vcf_list.txt](./examples/example_vcf_list.txt) into corresponding MAF files, which are then will be merged into one collective MAF file **example.maf** saved in **examples** directory.
>

<br>


## Converting ICGC mutation format to MAF

The publicly available ICGC mutation data is stored in [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) file, which is similar to MAF format in its structure, but the field names and classification of variants are different. The *[icgcMutationToMAF.R](./scripts/icgcMutationToMAF.R)* script implements *icgcSimpleMutationToMAF* function within *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* R package to convert ICGC [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) to MAF.


**Script**: *[icgcMutationToMAF.R](./scripts/icgcMutationToMAF.R)*

Argument | Description
------------ | ------------
--icgc_file | ICGC Simple Somatic Mutation Format file to be converted
--remove_duplicated_variants | Remove repeated variants in a particuar sample, mapped to multiple transcripts of same gene? (OPTIONAL; defulat is `TRUE`). **Note**, option `TRUE` removes all repeated variants as duplicated entries. `FALSE` results in keeping all of them)
--output | Output file name

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*

**Command line use example**:

```
Rscript icgcMutationToMAF.R --icgc_file /data/simple_somatic_mutation.open.PACA-AU.tsv --output simple_somatic_mutation.open.PACA-AU.maf
```
<br>


>This will convert the ***/data/simple_somatic_mutation.open.PACA-AU.tsv*** [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) file into [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) as output it as ***/data/simple_somatic_mutation.open.PACA-AU.maf***.

<br>

## Extracting variants within exonic regions

To extract variants detected within exonic regions run the *[exons_maf.pl](./scripts/exons_maf.pl)* script. It will create a MAF file with *.exonic.maf* extension, which will have the following variants included/excluded based on the input [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Variant_Classification* field:

Variants **included** | Variants **excluded**
------------ | ------------
Missense_Mutation, Nonsense_Mutation, Frame_Shift_Del, Frame_Shift_Ins, In_Frame_Del, In_Frame_Ins, Silent, Translation_Start_Site | 3'Flank, 3'UTR, 5'Flank, 5'UTR, IGR, Intron, RNA, Splice_Site, Splice_Region

<br />

**Script**: *[exons_maf.pl](./scripts/exons_maf.pl)*

Argument | Description
------------ | ------------
--maf | Full path with name of a MAF file to be converted

<br />

**Command line use example**:

```
perl exons_maf.pl --maf /data/simple_somatic_mutation.open.PACA-AU.maf
```

<br>


>This will extract variants within exonic regions reported in ***/data/simple_somatic_mutation.open.PACA-AU.maf*** file and will save them in ***/data/simple_somatic_mutation.open.PACA-AU.exonic.maf***.

<br>

## Changing sample names

To change sample names (as shown in [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field) run the *[MAFsamplesRename.R](./scripts/MAFsamplesRename.R)* script. It expects a file listing samples to be renamed. The first column is expected to contain sample names (as shown [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field) to be changed and the second columns is expected to contain the corresponding name to be used instead (see example file [example_samples_to_rename.txt](./examples/example_samples_to_rename.txt)).

<br />

**Script**: *[MAFsamplesRename.R](./scripts/MAFsamplesRename.R)*

Argument | Description
------------ | ------------
--maf_file | MAF file to be processed
--names_file | Name and path to a file listing samples to be renamed
--output | Name for the output MAF file

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*, *[tibble](https://cran.r-project.org/web/packages/tibble/tibble.pdf)*

**Command line use example**:

```
Rscript MAFsamplesRename.R --maf_file /data/simple_somatic_mutation.open.PACA-AU.maf --names_file /examples/example_samples_to_rename.txt --output /data/simple_somatic_mutation.open.PACA-AU_samples_renamed.maf
```

<br>

>This will create a ***/data/simple_somatic_mutation.open.PACA-AU_samples_renamed.maf*** with sample names changed according to ***/examples/example_samples_to_rename.txt*** file.

NOTE: If no output file name is specified the output will have the same name as the input *maf_file* with suffix *_samples_renamed.maf*.

<br>

## Subsetting MAF

To subset MAF based on a list of samples and/or genes run the *[subsetMAF.R](./scripts/subsetMAF.R)* script. It also allows to subset MAF based on variants classifiaction as defined in [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Variant_Classification* field. The script expects file(s) listing samples (as shown in [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field) and/or genes to include in the new MAF file (see example files [example_samples_to_subset.txt](./examples/example_samples_to_subset.txt) and [example_genes_to_subset.txt](./examples/example_genes_to_subset.txt)).

<br />

**Script**: *[subsetMAF.R](./scripts/subsetMAF.R)*

Argument | Description
------------ | ------------
--maf_file | MAF file to be subsetted
--samples | Name and path to a file listing samples to be kept in the subsetted MAF. Sample names are expected to be separated by comma. Use ***all*** to keep all samples (OPTIONAL)
--genes | Name and path to a file listing genes to be kept in the subsetted MAF. Gene symbols are expected to be separated by comma. Use ***all*** to keep all genes (OPTIONAL)
--var_class | Classification of variants to be kept in the subsetted MAF (OPTIONAL)
--output | Name for the subsetted MAF

NOTE: The available variants types for *var_class* parameter are listed in *Variant_Classification* row in the [MAF field requirements](https://github.com/umccr/MAF-summary#maf-field-requirements) section. 

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*

**Command line use example**:

```
Rscript subsetMAF.R --maf_file /data/simple_somatic_mutation.open.PACA-AU.maf --samples /examples/example_samples_to_subset.txt --genes /examples/example_ genes_to_subset.txt --var_class Missense_Mutation --output /data/simple_somatic_mutation.open.PACA-AU_subset.maf
```

<br>

>This will create a ***/data/simple_somatic_mutation.open.PACA-AU_subset.maf*** restricted to samples and genes listed in ***/examples/example_samples_to_subset.txt*** and ***/examples/example_ genes_to_subset.txt***, respectively, and containing missense mutations.

NOTE: If no output file name is specified the output will have the same name as the input *maf_file* with suffix *_subset.maf*.

<br>

## Merging MAFs

To merge multiple MAFs run the *[mergeMAFs.R](./scripts/mergeMAFs.R)* script. It uses [merge_mafs](https://rdrr.io/github/PoisonAlien/maftools/man/merge_mafs.html) function in [maftools R package](https://bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html), which merges MAFs based on [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field in each MAF file.

<br />

**Script**: *[mergeMAFs.R](./scripts/mergeMAFs.R)*

Argument | Description
------------ | ------------
--maf_dir | Directory with MAF files to be merged
--maf_files | List of MAF files to be merged. Each file name is expected to be separated by comma
--maf_fields | Fields to be kept in merged MAF. Options available: *All* (default), *Nonredundant* and *Basic*
--output | Name for the merged MAF file

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*

**Command line use example**:

```
Rscript mergeMAFs.R --maf_dir /data --maf_files simple_somatic_mutation.open.PACA-AU.maf,simple_somatic_mutation.open.PACA-CA.maf --maf_fields All --output icgc.simple_somatic_mutation.merged.maf
```

<br>

>This will create merged ***/data/icgc.simple_somatic_mutation.merged.maf*** file with mutation data from the individual ***/data/simple_somatic_mutation.open.PACA-AU.maf*** and ***/data/simple_somatic_mutation.open.PACA-CA.maf*** files.

NOTE: If no output file name is specified the output will be saved as *merged.maf* in the directory with MAF files to be merged.

<br>

## Summarising and visualising MAF file(s)

To summarise MAF file(s) run the *[summariseMAFs.R](./scripts/summariseMAFs.R)* script. This script catches the arguments from the command line and passes them to the *[summariseMAFs.Rmd](./scripts/summariseMAFs.Rmd)* script to produce the html report, generate set of plots and excel spreadsheets summarising each MAF file.

NOTE: Only non-synonymous variants with high/moderate variant consequences, including *frame shift deletions*, *frame shift insertions*, *splice site mutations*, *translation start site mutations* ,*nonsense mutation*, *nonstop mutations*, *in-frame deletion*, *in-frame insertions* and *missense mutation*, are reported (silent variants are ignored). One can manually define variant classifications to be considered as non-synonymous using `--nonSyn_list` parameter.

**Script**: *[summariseMAFs.R](./scripts/summariseMAFs.R)*

Argument | Description
------------ | ------------
--maf_dir | Directory with *MAF* file(s)
--maf_files | List of *MAF* file(s) to be processed. Each file name is expected to be separated by comma
--datasets | Desired names of each dataset. The names are expected to be in the same order as provided *MAF* files
--samples_id_cols | The name(s) of MAF file(s) column containing samples' IDs (OPTIONAL). One column name is expected for a single file, and each separated by comma. The defualt samples' ID column is "Tumor_Sample_Barcode"
--genes_min | Minimal percentage of patients carrying mutations in individual genes to be included in the report (OPTIONAL; default is `4`)
--genes_list | Location and name of a file listing genes of interest to be considered in the report (OPTIONAL)
--genes_blacklist | Location and name of a file listing genes to be excluded (OPTIONAL). Header is not expected and the genes should be listed in separate lines
--samples_list | Location and name of a file listing specific samples to be included (OPTIONAL). All other samples will be ignored. The ID of samples to be included are expected to be listed in column named "Tumor_Sample_Barcode". Additional columns are also allowed
--samples_blacklist | Location and name of a file listing samples to be excluded (OPTIONAL). The ID of samples to be excluded are expected to be listed in column named "Tumor_Sample_Barcode". Additional columns are allowed
--nonSyn_list | List of variant classifications to be considered as non-synonymous. Rest will be considered as silent variants. Default uses [Variant Classifications](http://asia.ensembl.org/Help/Glossary?id=535) with `High/Moderate variant consequences`
--remove_duplicated_variants | Remove repeated variants in a particuar sample, mapped to multiple transcripts of same gene? (OPTIONAL; defulat is `TRUE`). **Note**, option `TRUE` removes all repeated variants as duplicated entries. `FALSE` results in keeping all of them)
--out_folder | Output folder

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[openxlsx](https://cran.r-project.org/web/packages/openxlsx/openxlsx.pdf)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*, *[knitr](https://cran.r-project.org/web/packages/knitr/knitr.pdf)*, *[DT](https://rstudio.github.io/DT/)*, *[plotly](https://plot.ly/r/)*, *[heatmaply](https://cran.r-project.org/web/packages/heatmaply/vignettes/heatmaply.html)*, *[ggplot2](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf)*

**Command line use example**:

```
Rscript summariseMAFs.R --maf_dir /data --maf_files simple_somatic_mutation.open.PACA-AU.maf,simple_somatic_mutation.open.PACA-CA.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes_min 4 --out_folder MAF_summary_report
```
<br>

This will generate *[summariseMAFs.html](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFs.html)* report with interactive summary tables and heatmaps within *MAF_summary_report* folder. It will also create a folder with user-defined name containing output tables and plots described [here](README_output_files.md).

### Example output

Some example MAF files are located on [Spartan](https://dashboard.hpc.unimelb.edu.au/) cluster and are described in [Pancreatic-data-harmonization](https://github.com/umccr/Pancreatic-data-harmonization) repository.<br>

* [ICGC PACA-CA dataset](./examples/ICGC_PACA-CA_MAF_summary) &nbsp; ( <img src="img/flag-of-Canada.png" width="2.5%"> ) - includes descrition for output tables and plots
* [TCGA PAAD dataset](./examples/TCGA_PAAD_MAF_summary) &nbsp; ( <img src="img/flag-of-United-States-of-America.png" width="2.5%"> ) - highlihts sample demonstrating extremely high mutation burden
* [HTML report](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFs.html) - R html report for all datasets

<br />

## Summarising and visualising MAF file(s) for selected genes

To summarise MAF file(s) for specific set of genes run the *[summariseMAFsGenes.R](./scripts/summariseMAFsGenes.R)* script. This script catches the arguments from the command line and passes them to the *[summariseMAFsGenes.Rmd](./scripts/summariseMAFsGenes.Rmd)* script to produce the html report, generate set of plots and excel spreadsheets summarising user-defined genes for individual MAF files.

NOTE: Only non-synonymous variants with high/moderate variant consequences, including *frame shift deletions*, *frame shift deletions*, *splice site mutations*, *translation start site mutations* ,*nonsense mutation*, *nonstop mutations*, *in-frame deletion*, *in-frame insertions* and *missense mutation*, are reported (silent variants are ignored).

Make sure that *[X11](https://www.xquartz.org/)* is installed, as this is required to generate the interactive plots.

**Script**: *[summariseMAFsGenes.R](./scripts/summariseMAFsGenes.R)*

Argument | Description
------------ | ------------
--maf_dir | Directory with *MAF* file(s)
--maf_files | List of *MAF* file(s) to be processed. Each file name is expected to be separated by comma
--datasets | Desired names of each dataset. The names are expected to be in the same order as provided *MAF* files
--genes | Genes to query in each *MAF* file
--out_folder | Output folder

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[openxlsx](https://cran.r-project.org/web/packages/openxlsx/openxlsx.pdf)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*, *[knitr](https://cran.r-project.org/web/packages/knitr/knitr.pdf)*, *[DT](https://rstudio.github.io/DT/)*, *[plotly](https://plot.ly/r/)*, *[heatmaply](https://cran.r-project.org/web/packages/heatmaply/vignettes/heatmaply.html)*, *[ggplot2](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf)*

**Command line use example**:

```
Rscript summariseMAFsGenes.R --maf_dir /data --maf_files simple_somatic_mutation.open.PACA-AU.maf,simple_somatic_mutation.open.PACA-CA.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes KRAS,SMAD4,TP53,CDKN2A,ARID1A,BRCA1,BRCA2 --out_folder MAF_summary
```
<br>

This will generate *[summariseMAFsGenes.html](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFsGenes.html)* report with interactive summary tables and heatmaps within *MAF_summary* folder. It will also create a folder with user-defined name containing output tables and plots described [here](README_output_files.md).

### Example output

Some example MAF files are located on [Spartan](https://dashboard.hpc.unimelb.edu.au/) cluster and are described in [Pancreatic-data-harmonization](https://github.com/umccr/Pancreatic-data-harmonization) repository.<br>

* [HTML report](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFsGenes.html) - R html report for all datasets

<br>

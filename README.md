# MAF-summary

Set of scripts to **summarise**, **analyse** and **visualise** [Mutation Annotation Format](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) (MAF) file(s) using *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* R package. The maftools manuscript is on [bioRxiv](http://dx.doi.org/10.1101/052662) and scripts are available on [GitHub](https://github.com/PoisonAlien/maftools). The downstream analyses include [cancer driver discovery](https://github.com/umccr/driver-analysis).


## Table of contents

<!-- vim-markdown-toc GFM -->
* [Installation](#installation)
* [MAF field requirements](#maf-field-requirements)
* [Scripts summary](#scripts-summary)
* [Converting VCF files to MAF files](#converting-vcf-files-to-maf-files)
* [Converting ICGC mutation format to MAF](#converting-icgc-mutation-format-to-maf)
* [Extracting variants within exonic regions](#extracting-variants-within-exonic-regions)
* [Extracting variants of specific classification](#extracting-variants-of-specific-classification)
* [Changing sample names](#changing-sample-names)
* [Subsetting MAF](#subsetting-maf)
* [Merging MAFs](#merging-mafs)
* [Summarising and visualising MAF file(s)](#summarising-and-visualising-maf-files)
* [Summarising and visualising MAF file(s) for selected genes](#summarising-and-visualising-maf-files-for-selected-genes)

<!-- vim-markdown-toc -->
<br>

## Installation

Run the [environment.yaml](envm/environment.yaml) file to create *conda* environment and install required packages. The `-p` flag should point to the *miniconda* installation path. For instance, to create `maf-summary` environment using *miniconda* installed in `/miniconda` directory run the following command:

```
conda env create -p /miniconda/envs/maf-summary --file envm/environment.yaml
```

Activate created `maf-summary` *conda* environment before running the pipeline

```
conda activate maf-summary
```

Additionally, [vcf2maf](https://github.com/mskcc/vcf2maf) tool available on [GitHub](https://github.com/mskcc/vcf2maf) is required for [Converting VCF files to MAF files](#converting-vcf-files-to-maf-files).

<br />

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
*[var_class_maf.pl](./scripts/var_class_maf.pl)* | Extracts variants of specific classification/consequence
*[MAFsamplesRename.R](./scripts/MAFsamplesRename.R)* | Changes sample names in [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field
*[subsetMAF.R](./scripts/subsetMAF.R)* | Subsets MAF based on defined list of samples and/or genes
*[mergeMAFs.R](./scripts/mergeMAFs.R)* | Merges multiple MAFs
*[summariseMAFs.R](./scripts/summariseMAFs.R)* | Summarises and visualises [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file(s)
*[summariseMAFsGenes.R](./scripts/summariseMAFsGenes.R)* | Summarises and visualises [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file(s) for selected genes

<br />

## Converting VCF files to MAF files

To convert multiple VCF files into one collective MAF file use *[multi_vcf2maf.pl](./scripts/multi_vcf2maf.pl)* script. It requires a file with listed [VCF](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) files to be converted into corresponding MAF files (see an example [here](./examples/example_vcf_list.txt)). The individual MAF files are then merged into one collective MAF file, which is saved in the same directory as the files listing VCF files.

###### Note

The following are required

* [vcf2maf](https://github.com/mskcc/vcf2maf) tool available on [GitHub](https://github.com/mskcc/vcf2maf) (see [Installation](#installation) section).
* Reference FASTA file (e.g. [GRCh37](ftp://ftp.ncbi.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh37/special_requests/GRCh37-lite.fa.gz) available on [ncbi.nih.gov](ftp://ftp.ncbi.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh37/special_requests/GRCh37-lite.fa.gz) *FTP* site)

**Script**: *[multi_vcf2maf.pl](./scripts/multi_vcf2maf.pl)*


Argument | Description | Required
------------ | ------------ | ------------
--vcf_list | Full path with name of a file listing VCF files to be converted | **Yes**
--exons | Include exonic regions only: TRUE/T or FALSE/F (defualt) | No
--v2m | Full path to [vcf2maf.pl](https://github.com/mskcc/vcf2maf) script | **Yes**
--ref | Reference FASTA file (e.g. [GRCh37](ftp://ftp.ncbi.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh37/special_requests/GRCh37-lite.fa.gz)) | **Yes**
--maf_file | Name of the merged MAF file to be created | **Yes**

<br />

NOTE: The definition of **exonic regions** is based on the [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Variant_Classification* field and is described in [Extracting variants within exonic regions](#extracting-variants-within-exonic-regions) section. If one requires to subset generated [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file based on different *Variant_Classification* categories, then one can run the *[var_class_maf.pl](./scripts/var_class_maf.pl)* script, which allows define *Variant_Classification* categories of interest using ```--var_class``` parameter.

**Command line use example**:

```
perl scripts/multi_vcf2maf.pl  --vcf_list examples/example_vcf_list.txt  --exons FALSE  --v2m /path/to/vcf2maf.pl  --ref /path/to/reference/GRCh37-lite.fa  --maf_file example.maf
```

<br>

>This will convert the [VCF](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) files listed in [example_vcf_list.txt](./examples/example_vcf_list.txt) into corresponding MAF files, which are then will be merged into one collective MAF file **example.maf** saved in **examples** directory.
>

NOTE: Sometimes the [VCF](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) files miss the `chr` prefix for chromosome names, while these were present in the reference FASTA file (indicated by `--ref` parameter). This may trigger error similar to the one below:

```
[W::fai_get_val] Reference 10:69103935-69103937 not found in file, returning empty sequence
[faidx] Failed to fetch sequence in 10:69103935-69103937
ERROR: Make sure that ref-fasta is the same genome build as your MAF: ../GCF_000001405.38_GRCh38.p12_genomic.fna
```

To solve that issue one needs to add `chr` prefix to the [VCF](http://www.internationalgenome.org/wiki/Analysis/vcf4.0/) file of interest, e.g. `no_chr.vcf`:

```
awk '{if($0 !~ /^#/) print "chr"$0; else print $0}' no_chr.vcf > with_chr.vcf
```
 
<br>


## Converting ICGC mutation format to MAF

The publicly available ICGC mutation data is stored in [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) file, which is similar to MAF format in its structure, but the field names and classification of variants are different. The *[icgcMutationToMAF.R](./scripts/icgcMutationToMAF.R)* script implements *icgcSimpleMutationToMAF* function within *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)* R package to convert ICGC [Simple Somatic Mutation Format](http://docs.icgc.org/submission/guide/icgc-simple-somatic-mutation-format/) to MAF.


**Script**: *[icgcMutationToMAF.R](./scripts/icgcMutationToMAF.R)*

Argument | Description | Required
------------ | ------------ | ------------
--icgc_file | ICGC Simple Somatic Mutation Format file to be converted | **Yes**
--remove_duplicated_variants | Remove repeated variants in a particuar sample, mapped to multiple transcripts of same gene? (OPTIONAL; defulat is `TRUE`). **NOTE**, option `TRUE` removes all repeated variants as duplicated entries. `FALSE` results in keeping all of them) | No
--output | Output file name | No

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*

**Command line use example**:

```
gunzip examples/simple_somatic_mutation.open.PACA-AU.tsv.gz

Rscript scripts/icgcMutationToMAF.R --icgc_file examples/simple_somatic_mutation.open.PACA-AU.tsv --output simple_somatic_mutation.open.PACA-AU.maf
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

NOTE: If one requires to subset [MAF](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) file based on different *Variant_Classification* categories, then one can run the *[var_class_maf.pl](./scripts/var_class_maf.pl)* script, which allows define *Variant_Classification* categories of interest using ```--var_class``` parameter.

<br />

**Script**: *[exons_maf.pl](./scripts/exons_maf.pl)*

Argument | Description | Required
------------ | ------------ | ------------
--maf | Full path with name of a MAF file to be converted | **Yes**

<br />

**Command line use example**:

```
perl scripts/exons_maf.pl --maf examples/simple_somatic_mutation.open.PACA-AU.maf
```

<br>


>This will extract variants within exonic regions reported in ***/data/simple_somatic_mutation.open.PACA-AU.maf*** file and will save them in ***/data/simple_somatic_mutation.open.PACA-AU.exonic.maf***.

<br>

## Extracting variants of specific classification

To extract variants with specific consequences run the *[var_class_maf.pl](./scripts/var_class_maf.pl)* script. It will create a MAF file with *.var_class.maf* extension, which will have the user-defined variants included based on the input [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Variant_Classification* field.  Available options are listed in [MAF field requirements](#maf-field-requirements) section.:

**Script**: *[var_class_maf.pl](./scripts/var_class_maf.pl)*

Argument | Description | Required
------------ | ------------ | ------------
--maf | Full path with name of a MAF file to be converted | **Yes**
--var_class | List of variants classifications to incude in the subet MAF. The default list includes exonic regions, i.e. marked as *Missense_Mutation, Nonsense_Mutation, Frame_Shift_Del, Frame_Shift_Ins, In_Frame_Del, In_Frame_Ins, Silent* and *Translation_Start_Site* in [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Variant_Classification* field | No

<br />

**Command line use example**:

```
perl scripts/var_class_maf.pl --maf examples/simple_somatic_mutation.open.PACA-AU.maf --var_class Missense_Mutation,Nonsense_Mutation
```

<br>


>This will extract variants within exonic regions reported in ***/data/simple_somatic_mutation.open.PACA-AU.maf*** file and will save them in ***/data/simple_somatic_mutation.open.PACA-AU.var_class.maf***.

<br>


## Changing sample names

To change sample names (as shown in [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field) run the *[MAFsamplesRename.R](./scripts/MAFsamplesRename.R)* script. It expects a file listing samples to be renamed. The first column is expected to contain sample names (as shown [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field) to be changed and the second columns is expected to contain the corresponding name to be used instead (see example file [example_samples_to_rename.txt](./examples/example_samples_to_rename.txt)).

<br />

**Script**: *[MAFsamplesRename.R](./scripts/MAFsamplesRename.R)*

Argument | Description | Required
------------ | ------------ | ------------
--maf_file | MAF file to be processed | **Yes**
--names_file | Name and path to a file listing samples to be renamed | **Yes**
--output | Name for the output MAF file | No

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*, *[tibble](https://cran.r-project.org/web/packages/tibble/tibble.pdf)*

**Command line use example**:

```
Rscript scripts/MAFsamplesRename.R --maf_file examples/simple_somatic_mutation.open.PACA-AU.maf --names_file examples/example_samples_to_rename.txt --output examples/simple_somatic_mutation.open.PACA-AU_samples_renamed.maf
```

<br>

>This will create a ***/data/simple_somatic_mutation.open.PACA-AU_samples_renamed.maf*** with sample names changed according to ***/examples/example_samples_to_rename.txt*** file.

<br />

NOTE: If no output file name is specified the output will have the same name as the input *maf_file* with suffix *_samples_renamed.maf*.

<br>

## Subsetting MAF

To subset MAF based on a list of samples and/or genes run the *[subsetMAF.R](./scripts/subsetMAF.R)* script. It also allows to subset MAF based on variants classifiaction as defined in [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Variant_Classification* field. The script expects file(s) listing samples (as shown in [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field) and/or genes to include in the new MAF file (see example files [example_samples_to_subset.txt](./examples/example_samples_to_subset.txt) and [example_genes_to_subset.txt](./examples/example_genes_to_subset.txt)).

<br />

**Script**: *[subsetMAF.R](./scripts/subsetMAF.R)*

Argument | Description | Required
------------ | ------------ | ------------
--maf_file | MAF file to be subsetted | **Yes**
--samples | Name and path to a file listing samples to be kept in the subsetted MAF. Sample names are expected to be separated by comma. Use ***all*** to keep all samples (OPTIONAL) | No
--genes | Name and path to a file listing genes to be kept in the subsetted MAF. Gene symbols are expected to be separated by comma. Use ***all*** to keep all genes (OPTIONAL) | No
--var_class | Classification of variants to be kept in the subsetted MAF (OPTIONAL). Available options are listed in [MAF field requirements](#maf-field-requirements) section | No
--output | Name for the subsetted MAF | No

<br />

NOTE: The available variants types for *var_class* parameter are listed in *Variant_Classification* row in the [MAF field requirements](https://github.com/umccr/MAF-summary#maf-field-requirements) section. 

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*

**Command line use example**:

```
Rscript scripts/subsetMAF.R --maf_file examples/simple_somatic_mutation.open.PACA-AU.maf --samples examples/example_samples_to_subset.txt --genes examples/example_ genes_to_subset.txt --var_class Missense_Mutation --output examples/simple_somatic_mutation.open.PACA-AU_subset.maf
```

<br>

>This will create a ***/data/simple_somatic_mutation.open.PACA-AU_subset.maf*** restricted to samples and genes listed in ***/examples/example_samples_to_subset.txt*** and ***/examples/example_ genes_to_subset.txt***, respectively, and containing missense mutations.

NOTE: If no output file name is specified the output will have the same name as the input *maf_file* with suffix *_subset.maf*.

<br>

## Merging MAFs

To merge multiple MAFs run the *[mergeMAFs.R](./scripts/mergeMAFs.R)* script. It uses [merge_mafs](https://rdrr.io/github/PoisonAlien/maftools/man/merge_mafs.html) function in [maftools R package](https://bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html), which merges MAFs based on [MAF's](https://software.broadinstitute.org/software/igv/MutationAnnotationFormat) *Tumor_Sample_Barcode* field in each MAF file.

<br />

**Script**: *[mergeMAFs.R](./scripts/mergeMAFs.R)*

Argument | Description | Required
------------ | ------------ | ------------
--maf_dir | Directory with MAF files to be merged | **Yes**
--maf_files | List of MAF files to be merged. Each file name is expected to be separated by comma | **Yes**
--maf_fields | Fields to be kept in merged MAF. Options available: *All* (default), *Nonredundant* (i.e. those which are present in more than one dataset) and *Basic* (see [MAF field requirements](#maf-field-requirements) section) | No
--output | Location and name for the merged MAF file | No

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*

**Command line use example**:

```
Rscript scripts/mergeMAFs.R --maf_dir examples --maf_files simple_somatic_mutation.open.PACA-AU.maf,simple_somatic_mutation.open.PACA-CA.maf --maf_fields All --output examples/icgc.simple_somatic_mutation.merged.maf
```

<br>

>This will create merged ***/data/icgc.simple_somatic_mutation.merged.maf*** file with mutation data from the individual ***/data/simple_somatic_mutation.open.PACA-AU.maf*** and ***/data/simple_somatic_mutation.open.PACA-CA.maf*** files.

NOTE: If no output file name is specified the output will be saved as *merged.maf* in the directory with MAF files to be merged.

<br>

## Summarising and visualising MAF file(s)

To summarise MAF file(s) run the *[summariseMAFs.R](./scripts/summariseMAFs.R)* script. This script catches the arguments from the command line and passes them to the *[summariseMAFs.Rmd](./scripts/summariseMAFs.Rmd)* script to produce the html report, generate set of plots and excel spreadsheets summarising each MAF file.

NOTE: Only non-synonymous variants with high/moderate variant consequences, including *frame shift deletions*, *frame shift insertions*, *splice site mutations*, *translation start site mutations* ,*nonsense mutation*, *nonstop mutations*, *in-frame deletion*, *in-frame insertions* and *missense mutation*, are reported (silent variants are ignored). One can manually define variant classifications to be considered as non-synonymous using `--nonSyn_list` parameter.

**Script**: *[summariseMAFs.R](./scripts/summariseMAFs.R)*

Argument | Description | Required
------------ | ------------ | ------------
--maf_dir | Directory with *MAF* file(s) | **Yes**
--maf_files | List of *MAF* file(s) to be processed. Each file name is expected to be separated by comma | **Yes**
--datasets | Desired names of each dataset. The names are expected to be in the same order as provided *MAF* files | **Yes**
--samples_id_cols | The name(s) of MAF file(s) column containing samples' IDs. One column name is expected for a single file, and each separated by comma. The defualt samples' ID column is `Tumor_Sample_Barcode` | No
--genes_min | Minimal percentage of patients carrying mutations in individual genes to be included in the report (default is `4`) | No
--genes_list | Location and name of a file listing genes of interest to be considered in the report (OPTIONAL) | No
--genes_keep_order | Keep order of genes as provided in file specified by `genes_list` parameter (OPTIONAL; default is `FALSE`) | No
--genes_blacklist | Location and name of a file listing genes to be excluded (OPTIONAL). Header is not expected and the genes should be listed in separate lines | No
--samples_list | Location and name of a file listing specific samples to be included (OPTIONAL). All other samples will be ignored. The ID of samples to be included are expected to be listed in column named `Tumor_Sample_Barcode`. Additional columns are also allowed | No
--samples_keep_order | Keep order of samples as provided in the MAF file (OPTIONAL; default is `FALSE`).  | No
--samples_blacklist | Location and name of a file listing samples to be excluded (OPTIONAL). The ID of samples to be excluded are expected to be listed in column named `Tumor_Sample_Barcode`. Additional columns are allowed | No
--nonSyn_list | List of variant classifications to be considered as non-synonymous. Rest will be considered as silent variants. Default uses [Variant Classifications](http://asia.ensembl.org/Help/Glossary?id=535) with `High/Moderate variant consequences` | No
--remove_duplicated_variants | Remove repeated variants in a particuar sample, mapped to multiple transcripts of same gene? (defulat is `TRUE`). **NOTE**, option `TRUE` removes all repeated variants as duplicated entries. `FALSE` results in keeping all of them | No
--pathways | Location of a file with custom pathway list in the form of a two column tsv file containing gene names and their corresponding pathway (OPTIONAL) | No
--purple | Location of the corresponding [PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator) output files (OPTIONAL) | No
--purple_hd | Copy-number (CN) upper threshold to call homozygous deletion (HD) in [PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator) output files (OPTIONAL; defulat is `0.5`) | No
--purple_loh | CN upper threshold to call loss of heterozygosity (LOH) in [PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator) output files (OPTIONAL; defulat is `1.5`) | No
--purple_amp | CN lower threshold to call amplification in [PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator) output files (OPTIONAL; defulat is `6`) | No
--cnvkit | Location of the corresponding [CNVkit](https://cnvkit.readthedocs.io/en/stable/index.html) output files (OPTIONAL) | No
--cnvkit_hd | Copy-number (CN) upper threshold to call homozygous deletion (HD) in [CNVkit](https://cnvkit.readthedocs.io/en/stable/index.html) output files (OPTIONAL; defulat is `0.5`) | No
--cnvkit_loh | CN upper threshold to call loss of heterozygosity (LOH) in [CNVkit](https://cnvkit.readthedocs.io/en/stable/index.html) output files (OPTIONAL; defulat is `1.5`) | No
--cnvkit_amp | CN lower threshold to call amplification in [CNVkit](https://cnvkit.readthedocs.io/en/stable/index.html) output files (OPTIONAL; defulat is `6`) | No
--gistic | Location of the corresponding [GISTIC](http://software.broadinstitute.org/cancer/software/genepattern/modules/docs/GISTIC_2.0) output files (including *gisticAllLesionsFile*, *gisticAmpGenesFile*, *gisticDelGenesFile* and *gisticScoresFile*) (OPTIONAL) | No
--clinical_info | Location of clinical data associated with each sample in individual MAF file. Each file name (for each dataset) is expected to be separated by comma (OPTIONAL) | No
--clinical_features | Columns names (separated by comma) from clinical data (specified by *--clinical_info* argument) to be drawn in oncoplot(s) (OPTIONAL) | No
--clinical_enrichment_p | P-value threshold for clinical enrichment analysis (OPTIONAL; defulat is `0.05`) | No
--signature_enrichment_p | P-value threshold for reporting significant enrichment of genes in detected mutational signatures (OPTIONAL; defulat is `0.05`) | No
--maf_comp_p | P-value threshold for reporting significant differences between cohorts (OPTIONAL; defulat is `0.05`) | No
--maf_comp_fdr | FDR threshold for reporting significant differences between cohorts (OPTIONAL; defulat is `1`) | No
--out_folder | Output folder | No
--hide_code_btn | Hide the *Code* button allowing to show/hide code chunks in the final HTML report. Available options are: `TRUE` (default) and `FALSE` | No
--ucsc_genome_assembly | Human reference genome version used for signature analysis. Available options are: `19` (default) and `38` | No

<br />

**Packages**: required packages are listed in [environment.yaml](envm/environment.yaml) file.

###### Note

[Purple](https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator) output files can be combined and converted into [GISTIC](https://www.genepattern.org/modules/docs/GISTIC_2.0) compatible seg file using *[purple2gistic.R](./scripts/purple2gistic.R)* script. 

**Command line use example**:

```
cd scripts

Rscript summariseMAFs.R --maf_dir ../examples --maf_files simple_somatic_mutation.open.PACA-AU.maf,simple_somatic_mutation.open.PACA-CA.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes_min 4 --out_folder ../examples/MAF_summary_report
```
<br>

This will generate *[summariseMAFs.html](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFs.html)* report with interactive summary tables and heatmaps within *examples / MAF_summary_report* folder. It will also create `results` folder with user-defined name containing output tables and plots described [here](README_output_files.md).


<br />

## Summarising and visualising MAF file(s) for selected genes

To summarise MAF file(s) for specific set of genes run the *[summariseMAFsGenes.R](./scripts/summariseMAFsGenes.R)* script. This script catches the arguments from the command line and passes them to the *[summariseMAFsGenes.Rmd](./scripts/summariseMAFsGenes.Rmd)* script to produce the html report, generate set of plots and excel spreadsheets summarising user-defined genes for individual MAF files.

NOTE: Only non-synonymous variants with high/moderate variant consequences, including *frame shift deletions*, *frame shift deletions*, *splice site mutations*, *translation start site mutations* ,*nonsense mutation*, *nonstop mutations*, *in-frame deletion*, *in-frame insertions* and *missense mutation*, are reported (silent variants are ignored).

Make sure that *[X11](https://www.xquartz.org/)* is installed, as this is required to generate the interactive plots.

**Script**: *[summariseMAFsGenes.R](./scripts/summariseMAFsGenes.R)*

Argument | Description | Required
------------ | ------------ | ------------
--maf_dir | Directory with *MAF* file(s) | **Yes**
--maf_files | List of *MAF* file(s) to be processed. Each file name is expected to be separated by comma | **Yes**
--datasets | Desired names of each dataset. The names are expected to be in the same order as provided *MAF* files | **Yes**
--genes | Genes to query in each *MAF* file | **Yes**
--out_folder | Output folder | No

<br />

**Packages**: *[maftools](https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html)*, *[openxlsx](https://cran.r-project.org/web/packages/openxlsx/openxlsx.pdf)*, *[optparse](https://cran.r-project.org/web/packages/optparse/optparse.pdf)*, *[knitr](https://cran.r-project.org/web/packages/knitr/knitr.pdf)*, *[DT](https://rstudio.github.io/DT/)*, *[plotly](https://plot.ly/r/)*, *[heatmaply](https://cran.r-project.org/web/packages/heatmaply/vignettes/heatmaply.html)*, *[ggplot2](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf)*

**Command line use example**:

```
cd scripts

Rscript summariseMAFsGenes.R --maf_dir ../examples --maf_files simple_somatic_mutation.open.PACA-AU.maf,simple_somatic_mutation.open.PACA-CA.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes KRAS,SMAD4,TP53,CDKN2A,ARID1A,BRCA1,BRCA2 --out_folder ../examples/MAF_summary_report_genes
```
<br>

This will generate *[summariseMAFsGenes.html](https://rawgit.com/umccr/MAF-summary/master/scripts/summariseMAFsGenes.html)* report with interactive summary tables and heatmaps within *MAF_summary* folder. It will also create a folder with user-defined name containing output tables and plots described [here](README_output_files.md).

<br>

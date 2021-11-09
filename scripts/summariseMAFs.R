################################################################################
#
#   File name: summariseMAFs.R
#
#   Authors: Jacek Marzec ( jacek.marzec@unimelb.edu.au )
#
#   University of Melbourne Centre for Cancer Research,
#   Victorian Comprehensive Cancer Centre
#   305 Grattan St, Melbourne, VIC 3000
#
################################################################################

################################################################################
#
#   Description: Script summarising and visualising multiple MAF files using maftools R package ( https://bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html ). This script catches the arguments from the command line and passes them to the summariseMAFs.Rmd script to produce the report, generate set of plots and excel spreadsheets summarising each MAF file.
#   NOTE: Each MAF file needs to contain the "Tumor_Sample_Barcode" column. Otherwise, user needs to specify the MAF file column containing samples' IDs using "--samples_id_col" parameter.
#
#   Command line use example: Rscript summariseMAFs.R --maf_dir /data --maf_files simple_somatic_mutation.open.PACA-AU.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes_min 5 --genes_list genes_of_interest.txt --out_folder MAF_summary_report
#
#   maf_dir:      Directory with MAF files
#   maf_files:    List of MAF files to be processed. Each file name is expected to be separated by comma
#   datasets:     Desired names of each dataset. The names are expected to be in the same order as provided MAF files and should be separated by comma
#   samples_id_cols:  The name(s) of MAF file(s) column containing samples' IDs. One column name is expected for a single file, and each separated by comma. The default expected samples' ID column is "Tumor_Sample_Barcode"
#   genes_min:  Minimal percentage of patients carrying mutations in individual genes to be included in the report. Default is 5
#   genes_list (optional):  Location and name of a file listing genes of interest to be considered in the report. The genes are expected to be listed in first column
#   genes_keep_order (optional):  Keep order of genes as provided in the "genes_list" file. It refers to oncoplot of genes of interest only. Default is FALSE
#   genes_blacklist (optional):  Location and name of a file listing genes to be excluded. Header is not expected and the genes should be listed in separate lines
#   samples_list (optional):  Location and name of a file listing specific samples to be included. All other samples will be ignored. The ID of samples to be included are expected to be listed in column named "Tumor_Sample_Barcode". Additional columns are also allowed
#   samples_keep_order (optional):  Keep order of samples as provided in the MAF file. Default is FALSE
#   samples_keep_order_annot (optional):  Keep order of samples as provided in clinical data associated with each sample in MAF. Default is TRUE
#   sort_by_annotation (optional):  Sort samples by provided 'clinical_features'. Sorts based on first 'clinical_features'. Default is FALSE
#   samples_blacklist (optional):  Location and name of a file listing samples to be excluded. The ID of samples to be exdluded are expected to be listed in column named "Tumor_Sample_Barcode". Additional columns are also allowed
#   samples_show (optional):  Include sample names on the plots (oncoplots, oncogenic pathways plots, oncostrips). Default is FALSE
#   nonSyn_list:   List of variant classifications to be considered as non-synonymous. Rest will be considered as silent variants
#	  remove_duplicated_variants:		Remove repeated variants in a particular sample, mapped to multiple transcripts of same gene? Defulat value is "FALSE"
#   pathways (optional):  Location of a file with custom pathway list in the form of a two column tsv file containing gene names and their corresponding pathway
#   purple (optional):  Location of the PURPLE ".purple.cnv.gene.tsv" output files. Each location (for each dataset) is expected to be separated by comma
#   purple_hd (optional): Purple CN upper threshold to call homozygous deletions (HD)
#   purple_loh (optional): Purple CN upper threshold to call loss of heterozygosity (LOH)
#   purple_amp (optional): Purple CN lower threshold to call amplification (Amp)
#   cnvkit (optional):  Location of the PURPLE "-cnvkit-call.cns" output files. Each location (for each dataset) is expected to be separated by comma
#   cnvkit_hd (optional): CNVkit CN upper threshold to call homozygous deletions (HD)
#   cnvkit_loh (optional): CNVkit CN upper threshold to call loss of heterozygosity (LOH)
#   cnvkit_amp (optional): CNVkit CN lower threshold to call amplification (Amp)
#   gistic (optional):  Location of the corresponding GISTIC output files (including gisticAllLesionsFile, gisticAmpGenesFile, gisticDelGenesFile and gisticScoresFile). Each file name (for each dataset) is expected to be separated by comma
#   draw_titv:  Logical whether to include TiTv plot. Defualt value is "FALSE"
#   clinical_info (optional):  Location of clinical data associated with each sample in MAF. Each file name (for each dataset) is expected to be separated by comma
#   clinical_features (optional):  Columns names (separated by comma) from clinical data (specified by --clinical_info argument) to be drawn in the oncoplot(s). Note that the order matters
#   clinical_enrichment_p (optional):   P-value threshold for clinical enrichment analysis. Defualt value is 0.05
#   signature_enrichment_p (optional):   P-value threshold for reporting significant enrichment of genes in detected mutational signatures. Defualt value is 0.05
#   maf_comp_p (optional):   P-value threshold for reporting significant differences between cohorts. Defualt value is 0.05
#   maf_comp_fdr (optional):   FDR threshold for reporting significant differences between cohorts. Defualt value is 1
#   out_folder:   Name for the output folder that will be created within the directory with MAF files. If no output folder is specified the results will be saved in folder "MAF_summary_report"
#   hide_code_btn : Hide the "Code" button allowing to show/hide code chunks in the final HTML report. Available options are: "TRUE" (default) and "FALSE"
#   ucsc_genome_assembly :  Human reference genome version used for signature analysis (default is "19")
#
################################################################################

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(optparse))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list <- list(
  make_option("--maf_dir", action="store", default=NA, type='character',
              help="Directory with MAF files"),
  make_option("--maf_files", action="store", default=NA, type='character',
              help="List of MAF files to be processed"),
  make_option("--datasets", action="store", default=NA, type='character',
              help="Desired names of each dataset"),
  make_option("--samples_id_cols", action="store", default=NULL, type='character',
              help="The name(s) of MAF file(s) column containing samples' IDs"),
  make_option("--genes_min", action="store", default="5", type='character',
              help="Minimal percentage of patients carrying mutations in individual genes to be included in the report"),
  make_option("--genes_list", action="store", default="none", type='character',
              help="Location and name of a file listing genes of interest to be considered in the report"),
  make_option("--genes_keep_order", action="store", default=FALSE, type='logical',
              help="Keep order of genes as provided in the 'genes_list' file"),
  make_option("--genes_blacklist", action="store", default="none", type='character',
              help="Location and name of a file listing genes to be excluded"),
  make_option("--samples_list", action="store", default="none", type='character',
              help="Location and name of a file listing specific samples to be included"),
  make_option("--samples_keep_order", action="store", default=FALSE, type='logical',
              help="Keep order of samples as provided in the MAF file"),
  make_option("--samples_keep_order_annot", action="store", default=TRUE, type='logical',
              help="Keep order of samples as provided in clinical data associated with each sample in MAF"),
  make_option("--sort_by_annotation", action="store", default=FALSE, type='logical',
              help="Sort samples by provided clinical_features"),  
  make_option("--samples_blacklist", action="store", default="none", type='character',
              help="Location and name of a file listing samples to be excluded"),
  make_option("--samples_show", action="store", default=FALSE, type='logical',
              help="Include sample names on the plots"),
  make_option("--nonSyn_list", action="store", default=NA, type='character',
              help="List of variant classifications to be considered as non-synonymous"),
  make_option("--remove_duplicated_variants", action="store", default=NA, type='character',
              help="Remove repeated variants in a particuar sample, mapped to multiple transcripts of same gene?"),
  make_option("--pathways", action="store", default="none", type='character',
              help="Location of a file with custom pathway list"),
  make_option("--purple", action="store", default="none", type='character',
              help="Location of the PURPLE output files"),
  make_option("--purple_hd", action="store", default=0.5, type='double',
              help="PURPLE CN upper threshold to call HD"),
  make_option("--purple_loh", action="store", default=1.5, type='double',
              help="PURPLE CN upper threshold to call LOH"),
  make_option("--purple_amp", action="store", default=6, type='double',
              help="PURPLE CN lower threshold to call LOH"),
  make_option("--cnvkit", action="store", default="none", type='character',
              help="Location of the CNVkit output files"),
  make_option("--cnvkit_hd", action="store", default=0.5, type='double',
              help="CNVkit CN upper threshold to call HD"),
  make_option("--cnvkit_loh", action="store", default=1.5, type='double',
              help="CNVkit CN upper threshold to call LOH"),
  make_option("--cnvkit_amp", action="store", default=6, type='double',
              help="CNVkit CN lower threshold to call LOH"),
  make_option("--gistic", action="store", default="none", type='character',
              help="Location of the corresponding GISTIC output files"),
  make_option("--draw_titv", action="store", default=FALSE, type='logical',
              help="Logical whether to include TiTv plot"),
  make_option("--clinical_info", action="store", default="none", type='character',
              help="Location of clinical data associated with each sample in MAF"),
  make_option("--clinical_features", action="store", default="none", type='character',
              help="Columns names from clinical data to be drawn in the oncoplot(s)"),
  make_option("--clinical_enrichment_p", action="store", default=0.05, type='double',
              help="P-value threshold for clinical enrichment analysis"),
  make_option("--signature_enrichment_p", action="store", default=0.05, type='double',
              help="P-value threshold for reporting significant enrichment of genes in detected mutational signatures"),
  make_option("--maf_comp_p", action="store", default=0.05, type='double',
              help="P-value threshold for reporting significant differences between cohorts"),
  make_option("--maf_comp_fdr", action="store", default=1, type='double',
              help="FDR threshold for reporting significant differences between cohorts"),  
  make_option("--out_folder", action="store", default=NA, type='character',
              help="Output directory"),
  make_option("--hide_code_btn", action="store", default=TRUE, type='logical',
              help="Hide the \"Code\" button allowing to show/hide code chunks in the final HTML report"),
  make_option("--ucsc_genome_assembly", action="store", default=19, type='integer',
              help="human reference genome version used for signature analysis")
)

opt <- parse_args(OptionParser(option_list=option_list))

##### Collect MAF files and correspondiong datasets names
opt$maf_files <- gsub("\\s","", opt$maf_files)
opt$gistic <- gsub("\\s","", opt$gistic)
opt$purple <- gsub("\\s","", opt$purple)
opt$clinical_info <- gsub("\\s","", opt$clinical_info)
opt$datasets <- gsub("\\s","", opt$datasets)

##### Read in argument from command line and check if all were provide by the user
if (is.na(opt$maf_dir) || is.na(opt$maf_files) || is.na(opt$datasets) ) {

  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript summariseMAFs.R --maf_dir /data --maf_filessimple_somatic_mutation.open.PACA-AU.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes_min 5 --genes_list genes_of_interest.txt --out_folder MAF_summary_report\n\n")

  q()
} else if ( length(unlist(strsplit(opt$maf_files, split=',', fixed=TRUE))) != length(unlist(strsplit(opt$datasets, split=',', fixed=TRUE))) ) {

  cat("\nMake sure that the number of datasets names match the number of queried MAF files\n\n")

  q()
}

if ( !is.null(opt$samples_id_cols) && length(unlist(strsplit(opt$maf_files, split=',', fixed=TRUE))) != length(unlist(strsplit(opt$samples_id_cols, split=',', fixed=TRUE))) ) {
  
  cat("\nMake sure that the number of samples' ID columns match the number of queried MAF files\n\n")
  
  q()
}

##### Write the results into folder "MAF_summary_report" if no output directory is specified
if ( is.na(opt$out_folder) ) {
	opt$out_folder<- "MAF_summary_report"
}

##### Present genes with mutations present in >= 4% patients, if not specified differently
if ( is.na(opt$genes_min) ) {
  opt$genes_min<- "5"
}

##### Pre-define list of variant classifications to be considered as non-synonymous. Rest will be considered as silent variants. Default uses Variant Classifications with High/Moderate variant consequences (http://asia.ensembl.org/Help/Glossary?id=535)
if ( is.na(opt$nonSyn_list) ) {
  opt$nonSyn_list<- c("Frame_Shift_Del","Frame_Shift_Ins","Splice_Site","Translation_Start_Site","Nonsense_Mutation","Nonstop_Mutation","In_Frame_Del","In_Frame_Ins","Missense_Mutation")
} else {
  opt$nonSyn_list <- unlist(strsplit(opt$nonSyn_list, split=',', fixed=TRUE))
}

##### Set defualt paramters
if ( is.na(opt$remove_duplicated_variants) ) {
  opt$remove_duplicated_variants = FALSE
}

if ( opt$ucsc_genome_assembly !=19 && opt$ucsc_genome_assembly !=38   ) {
  cat("\nCurrently human reference genome versions \"19\" and \"38\" are supported.\n\n")
  q()
}

##### Check input paramters
if ( tolower(opt$remove_duplicated_variants) != "true" && tolower(opt$remove_duplicated_variants) != "false"  ) {
  cat("\nMake sure that the \"--removeDuplicatedVariants\" parameter is set to \"TRUE\" or \"FALSE\"!\n\n")
  q()
}

##### Make sure that only PURPLE or GISTIC results are provided, not both
if ( opt$purple != "none" && opt$gistic != "none" ) {
  cat("\nMake sure that only PURPLE (\"--purple\") or GISTIC (\"--gistic\") results are provided!\n\n")
  q()  
}

##### Collect parameters
param_list <- list(maf_dir = opt$maf_dir,
                   maf_files = opt$maf_files,
                   datasets = opt$datasets,
                   samples_id_cols = opt$samples_id_cols,
                   genes_min = opt$genes_min,
                   genes_list = opt$genes_list,
                   genes_keep_order = opt$genes_keep_order,
                   genes_blacklist = opt$genes_blacklist,
                   samples_list = opt$samples_list,
                   samples_keep_order = opt$samples_keep_order,
                   samples_keep_order_annot = opt$samples_keep_order_annot,
                   sort_by_annotation = opt$sort_by_annotation,
                   samples_blacklist = opt$samples_blacklist,
                   samples_show = opt$samples_show,
                   nonSyn_list = opt$nonSyn_list,
                   remove_duplicated_variants = opt$remove_duplicated_variants,
                   pathways = opt$pathways,
                   purple = opt$purple,
                   purple_hd = opt$purple_hd,
                   purple_loh = opt$purple_loh,
                   purple_amp = opt$purple_amp,
                   cnvkit = opt$cnvkit,
                   cnvkit_hd = opt$cnvkit_hd,
                   cnvkit_loh = opt$cnvkit_loh,
                   cnvkit_amp = opt$cnvkit_amp,
                   gistic = opt$gistic,
                   draw_titv = opt$draw_titv,
                   clinical_info = opt$clinical_info,
                   clinical_features = opt$clinical_features,
                   clinical_enrichment_p = opt$clinical_enrichment_p,
                   signature_enrichment_p = opt$signature_enrichment_p,
                   maf_comp_p = opt$maf_comp_p,
                   maf_comp_fdr = opt$maf_comp_fdr,
                   out_folder = opt$out_folder,
                   hide_code_btn = opt$hide_code_btn,
                   ucsc_genome_assembly = as.numeric(opt$ucsc_genome_assembly)
                   )

##### Pass the user-defined argumentas to the summariseMAFs.R markdown script and run the analysis
rmarkdown::render(input = "summariseMAFs.Rmd",
                  output_dir = paste(opt$maf_dir, opt$out_folder, sep = "/"),
                  output_file = paste0(opt$out_folder, ".html"),
                  params = param_list)

##### Remove the assocaited MD file and the redundant folder with plots that are imbedded in the HTML report
unlink(paste0(opt$maf_dir, "/", opt$out_folder, "_files"), recursive = TRUE)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()


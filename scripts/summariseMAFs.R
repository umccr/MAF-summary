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
#   Command line use example: Rscript summariseMAFs.R --maf_dir /data --maf_filessimple_somatic_mutation.open.PACA-AU.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes_min 4 --genes_list genes_of_interest.txt --out_folder MAF_summary_report
#
#   maf_dir:      Directory with MAF files
#   maf_files:    List of MAF files to be processed. Each file name is expected to be separated by comma
#   datasets:     Desired names of each dataset. The names are expected to be in the same order as provided MAF files and should be separated by comma
#   samples_id_cols (optional):  The name(s) of MAF file(s) column containing samples' IDs. One column name is expected for a single file, and each separated by comma. The defualt samples' ID column is "Tumor_Sample_Barcode"
#   genes_min (optional):  Minimal percentage of patients carrying mutations in individual genes to be included in the report
#   genes_list (optional):  Location and name of a file listing genes of interest to be considered in the report. The genes are expected to be listed in first column
#   genes_blacklist (optional):  Location and name of a file listing genes to be excluded. Header is not expected and the genes should be listed in separate lines
#   samples_list (optional):  Location and name of a file listing specific samples to be included. All other samples will be ignored. The ID of samples to be included are expected to be listed in column named "Tumor_Sample_Barcode". Additional columns are also allowed
#   samples_blacklist (optional):  Location and name of a file listing samples to be excluded. The ID of samples to be exdluded are expected to be listed in column named "Tumor_Sample_Barcode". Additional columns are also allowed
#   nonSyn_list (optional):   List of variant classifications to be considered as non-synonymous. Rest will be considered as silent variants
#   out_folder:      Name for the output folder that will be created within the directory with MAF files. If no output folder is specified the results will be saved in folder "MAF_summary_report"
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
  make_option(c("-d", "--maf_dir"), action="store", default=NA, type='character',
              help="Directory with MAF files"),
  make_option(c("-m", "--maf_files"), action="store", default=NA, type='character',
              help="List of MAF files to be processed"),
  make_option(c("-c", "--datasets"), action="store", default=NA, type='character',
              help="Desired names of each dataset"),
  make_option(c("-a", "--samples_id_cols"), action="store", default=NA, type='character',
              help="The name(s) of MAF file(s) column containing samples' IDs"),
  make_option(c("-g", "--genes_min"), action="store", default=NA, type='character',
              help="Minimal percentage of patients carrying mutations in individual genes to be included in the report"),
  make_option(c("-l", "--genes_list"), action="store", default=NA, type='character',
              help="Location and name of a file listing genes of interest to be considered in the report"),
  make_option(c("-r", "--genes_blacklist"), action="store", default=NA, type='character',
              help="Location and name of a file listing genes to be excluded"),
  make_option(c("-i", "--samples_list"), action="store", default=NA, type='character',
              help="Location and name of a file listing specific samples to be included"),
  make_option(c("-s", "--samples_blacklist"), action="store", default=NA, type='character',
              help="Location and name of a file listing samples to be excluded"),
  make_option(c("-n", "--nonSyn_list"), action="store", default=NA, type='character',
              help="List of variant classifications to be considered as non-synonymous"),
  make_option(c("-o", "--out_folder"), action="store", default=NA, type='character',
              help="Output directory")
)

opt <- parse_args(OptionParser(option_list=option_list))

##### Collect MAF files and correspondiong datasets names
opt$maf_files <- gsub("\\s","", opt$maf_files)
opt$datasets <- gsub("\\s","", opt$datasets)

##### Read in argument from command line and check if all were provide by the user
if (is.na(opt$maf_dir) || is.na(opt$maf_files) || is.na(opt$datasets) ) {

  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript summariseMAFs.R --maf_dir /data --maf_filessimple_somatic_mutation.open.PACA-AU.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes_min 4 --genes_list genes_of_interest.txt --out_folder MAF_summary_report\n\n")

  q()
} else if ( length(unlist(strsplit(opt$maf_files, split=',', fixed=TRUE))) != length(unlist(strsplit(opt$datasets, split=',', fixed=TRUE))) ) {

  cat("\nMake sure that the number of datasets names match the number of queried MAF files\n\n")

  q()
}

if ( !is.na(opt$samples_id_cols) && length(unlist(strsplit(opt$maf_files, split=',', fixed=TRUE))) != length(unlist(strsplit(opt$samples_id_cols, split=',', fixed=TRUE))) ) {
  
  cat("\nMake sure that the number of samples' ID columns match the number of queried MAF files\n\n")
  
  q()
}

##### Write the results into folder "MAF_summary_report" if no output directory is specified
if ( is.na(opt$out_folder) ) {
	opt$out_folder<- "MAF_summary_report"
}

##### Present genes with mutations present in >= 4% patients, if not specified differently
if ( is.na(opt$genes_min) ) {
  opt$genes_min<- 4
}

##### Pre-define list of variant classifications to be considered as non-synonymous. Rest will be considered as silent variants. Default uses Variant Classifications with High/Moderate variant consequences (http://asia.ensembl.org/Help/Glossary?id=535)
if ( is.na(opt$nonSyn_list) ) {
  opt$nonSyn_list<- c("Frame_Shift_Del","Frame_Shift_Ins","Splice_Site","Translation_Start_Site","Nonsense_Mutation", "Nonstop_Mutation", "In_Frame_Del","In_Frame_Ins", "Missense_Mutation")
} else {
  opt$nonSyn_list <- unlist(strsplit(opt$nonSyn_list, split=',', fixed=TRUE))
}

##### Pass the user-defined argumentas to the summariseMAFs.R markdown script and run the analysis
rmarkdown::render(input = "summariseMAFs.Rmd", output_dir = paste(opt$maf_dir, opt$out_folder, "Report", sep = "/"), output_file = paste0(opt$out_folder, ".html"), params = list(maf_dir = opt$maf_dir, maf_files = opt$maf_files, datasets = opt$datasets, samples_id_cols = opt$samples_id_cols, genes_min = opt$genes_min, genes_list = opt$genes_list, genes_blacklist = opt$genes_blacklist, samples_list = opt$samples_list, samples_blacklist = opt$samples_blacklist, nonSyn_list = opt$nonSyn_list, out_folder = opt$out_folder))

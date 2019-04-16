################################################################################
#
#   File name: driverAnalysis.R
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
#   Description: Script for selection analyses and cancer driver discovery results. This script catches the arguments from the command line and passes them to the driverAnalysis.Rmd script to produce the report, generate set of plots and tables.
#
#   Command line use example: Rscript driverAnalysis.R --maf_dir /data --maf_filessimple_somatic_mutation.open.PACA-AU.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --q_value 0.1 --ratios_ci FALSE --hypermut_sample_cutoff 3000 --max_muts_per_gene 3 --ucsc_genome_assembly 19 --out_folder Driver_analysis_report
#
#   maf_dir:      Directory with MAF files
#   maf_files:    List of MAF files to be processed. Each file name is expected to be separated by comma
#   datasets:     Desired names of each dataset. The names are expected to be in the same order as provided MAF files and should be separated by comma
#   genes_list (optional):  Location and name of a file listing genes of interest to be considered in the report. The genes are expected to be listed in first column
#   q_value:      q-value threshold for reporting significant genes (defualt 0.1)
#   ratios_ci:    Calculate per-gene confidence intervals for the dN/dS ratios (default FALSE)
#   hypermut_sample_cutoff:   Mutations per gene to define ultra-hypermutator samples (these will be excluded; defualt 3000)
#   max_muts_per_gene:   Maximum mutations per gene in same sample (remaining will be subsampled; defualt 3)
#   ucsc_genome_assembly:   Version of UCSC genome assembly to be used as a reference
#   out_folder:   Name for the output folder that will be created within the directory with MAF files. If no output folder is specified the results will be saved in folder "Driver_analysis_report"
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
  make_option(c("-l", "--genes_list"), action="store", default=NA, type='character',
              help="Location and name of a file listing genes of interest to be considered in the report"),
  make_option(c("-q", "--q_value"), action="store", default=NA, type='character',
              help="q-value threshold for reporting significant genes"),
  make_option(c("-r", "--ratios_ci"), action="store", default=NA, type='character',
              help="Calculate per-gene confidence intervals for the dN/dS ratios"),
  make_option(c("-u", "--hypermut_sample_cutoff"), action="store", default=NA, type='character',
              help="Mutations per gene to define ultra-hypermutator samples"),
  make_option(c("-s", "--max_muts_per_gene"), action="store", default=NA, type='character',
              help="Maximum mutations per gene in same sample"),
  make_option(c("-g", "--ucsc_genome_assembly"), action="store", default=NA, type='character',
              help="Version of UCSC genome assembly to be used as a reference"),
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
  cat("\ncommand example:\n\nRscript driverAnalysis.R --maf_dir /data --maf_filessimple_somatic_mutation.open.PACA-AU.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --q_value 0.1 --ratios_ci FALSE --hypermut_sample_cutoff 3000 --max_muts_per_gene 3 --ucsc_genome_assembly 19 --out_folder Driver_analysis_report\n\n")
  q()
  
} else if ( length(unlist(strsplit(opt$maf_files, split=',', fixed=TRUE))) != length(unlist(strsplit(opt$datasets, split=',', fixed=TRUE))) ) {

  cat("\nMake sure that the number of datasets names match the number of queried MAF files\n\n")
  q()
}

##### Write the results into folder "Driver_analysis_report" if no output directory is specified
if ( is.na(opt$out_folder) ) {
	opt$out_folder<- "Driver_analysis_report"
}

##### Don't present mutations for any additional genes if not specified by user
if ( is.na(opt$genes_list) ) {
  opt$genes_list<- NULL
}

##### See default for q-value threshold
if ( is.na(opt$q_value) ) {
  opt$q_value <- 0.1
}

##### See default for per-gene confidence intervalsd
if ( is.na(opt$ratios_ci) ) {
  
  opt$ratios_ci <- FALSE
  
} else if ( as.character(opt$ratios_ci) != "FALSE" && as.character(opt$ratios_ci) != "TRUE" ) {
  
  cat("\nMake sure that the \"ratios_ci\" is either \"TRUE\" or \"FALSE\"\n\n")
  q()
}

##### See default for calling ultra-hypermutator samples
if ( is.na(opt$hypermut_sample_cutoff) ) {
  opt$hypermut_sample_cutoff <- 3000
}

##### See default for maximum mutations per gene in same sample
if ( is.na(opt$max_muts_per_gene) ) {
  opt$max_muts_per_gene <- 3
}

##### See default for UCSC genome assembly version
if ( is.na(opt$ucsc_genome_assembly) ) {
  opt$ucsc_genome_assembly <- 19
}

##### Pass the user-defined argumentas to the driverAnalysis.R markdown script and run the analysis
rmarkdown::render(input = "driverAnalysis.Rmd", output_dir = paste(opt$maf_dir, opt$out_folder, sep = "/"), output_file = paste0(opt$out_folder, ".html"), params = list(maf_dir = opt$maf_dir, maf_files = opt$maf_files, datasets = opt$datasets, genes_list = opt$genes_list, q_value = as.numeric(opt$q_value), ratios_ci = as.logical(opt$ratios_ci), hypermut_sample_cutoff = as.numeric(opt$hypermut_sample_cutoff), max_muts_per_gene = as.numeric(opt$max_muts_per_gene), ucsc_genome_assembly = as.numeric(opt$ucsc_genome_assembly), out_folder = opt$out_folder))

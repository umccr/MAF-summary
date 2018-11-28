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
#   NOTE: Each MAF file needs to contain the "Tumor_Sample_Barcode" column.
#
#   Command line use example: Rscript summariseMAFs.R --maf_dir /data --maf_filessimple_somatic_mutation.open.PACA-AU.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes_no 20 --out_dir MAF_summary
#
#   maf_dir:      Directory with MAF files
#   maf_files:    List of MAF files to be processed. Each file name is expected to be separated by comma
#   datasets:     Desired names of each dataset. The names are expected to be in the same order as provided MAF files and should be separated by comma
#   genes_no (optional):  Number of the most frequently mutated genes to present
#   out_dir:      Name for the output directory that will be created within the directory with MAF files. If no output directory is specified the results will be saved in folder "MAF_summary"
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
  make_option(c("-g", "--genes_no"), action="store", default=NA, type='character',
              help="Number of the most frequently mutated genes to present"),
  make_option(c("-o", "--out_dir"), action="store", default=NA, type='character',
              help="Output directory")
)

opt <- parse_args(OptionParser(option_list=option_list))

##### Collect MAF files and correspondiong datasets names
opt$maf_files <- gsub("\\s","", opt$maf_files)
opt$datasets <- gsub("\\s","", opt$datasets)

##### Read in argument from command line and check if all were provide by the user
if (is.na(opt$maf_dir) || is.na(opt$maf_files) || is.na(opt$datasets) ) {

  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript summariseMAFs.R --maf_dir /data --maf_filessimple_somatic_mutation.open.PACA-AU.maf,PACA-CA.icgc.simple_somatic_mutation.maf --datasets ICGC-PACA-AU,ICGC-PACA-CA --genes_no 20 --out_dir MAF_summary\n\n")

  q()
} else if ( length(unlist(strsplit(opt$maf_files, split=',', fixed=TRUE))) != length(unlist(strsplit(opt$datasets, split=',', fixed=TRUE))) ) {

  cat("\nMake sure that the number of datasets names match the number of queried MAF files\n\n")

  q()
}

##### Write the results into folder "MAF_summary" if no output directory is specified
if ( is.na(opt$out_dir) ) {
	opt$out_dir<- "MAF_summary"
}

##### Present the top 20 most frequently mutated genes if not specified differently
if ( is.na(opt$genes_no) ) {
  opt$genes_no<- 20
}

##### Pass the user-defined argumentas to the summariseMAFs.R markdown script and run the analysis
rmarkdown::render(input = "summariseMAFs.Rmd", output_dir = paste(opt$maf_dir, opt$out_dir, "Report", sep = "/"), params = list(maf_dir = opt$maf_dir, maf_files = opt$maf_files, datasets = opt$datasets, genes_no = opt$genes_no, out_dir = opt$out_dir))

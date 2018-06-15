################################################################################
#
#   File name: summariseMAFsGenes.R
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
#	  Description: Script summarising and visualising multiple MAF files using maftools R package ( https://bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html ).
#   NOTE: Each MAF file needs to contain the "Tumor_Sample_Barcode" column.
#
#   Command line use example: Rscript summariseMAFsGenes.R --maf_dir /data --maf_files PACA-AU.icgc.simple_somatic_mutation.maf,PACA-CA.icgc.simple_somatic_mutation.maf --cohorts ICGC-PACA-AU,ICGC-PACA-CA --genes KRAS,SMAD4,TP53,CDKN2A,ARID1A,BRCA1,BRCA2 --out_dir MAF_summary_genes
#
#   maf_dir:      Directory with MAF files
#   maf_files:    List of MAF files to be processed. Each file name is expected to be separated by comma
#   cohorts:      Desired names of each cohort. The names are expected to be in the same order as provided MAF files and should be separated by comma
#   genes:        Genes to query
#   out_dir:      Name for the output directory that will be created within the directory with MAF files. If no output directory is specified the results will be saved in folder "MAF_summary"
#
################################################################################

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

#===============================================================================
#    Functions
#===============================================================================

#===============================================================================
#    Load libraries
#===============================================================================

##### Set the jave max heap size to 2Gb to accomodate big gene tables
options( java.parameters = "-Xmx2000m" )

suppressMessages(library(maftools))
suppressMessages(library(xlsx))
suppressMessages(library(optparse))


#===============================================================================
#    Catching the arguments
#===============================================================================
option_list <- list(
  make_option(c("-d", "--maf_dir"), action="store", default=NA, type='character',
              help="Directory with MAF files"),
  make_option(c("-m", "--maf_files"), action="store", default=NA, type='character',
              help="List of MAF files to be processed"),
  make_option(c("-c", "--cohorts"), action="store", default=NA, type='character',
              help="Desired names of each cohort"),
  make_option(c("-g", "--genes"), action="store", default=NA, type='character',
              help="Genes to query"),
  make_option(c("-o", "--out_dir"), action="store", default=NA, type='character',
              help="Output directory")
)

opt <- parse_args(OptionParser(option_list=option_list))

##### Split the string of MAF files and cohort names put into a vector
opt$maf_files <- gsub("\\s","", opt$maf_files)
opt$maf_files <-  unlist(strsplit(opt$maf_files, split=',', fixed=TRUE))
opt$maf_files <- paste(opt$maf_dir, opt$maf_files, sep="/")

opt$cohorts <- gsub("\\s","", opt$cohorts)
opt$cohorts <- unlist(strsplit(opt$cohorts, split=',', fixed=TRUE))

opt$genes <- gsub("\\s","", opt$genes)
opt$genes <- unlist(strsplit(opt$genes, split=',', fixed=TRUE))

##### Read in argument from command line and check if all were provide by the user
if (is.na(opt$maf_dir) || is.na(opt$maf_files) || is.na(opt$cohorts) || is.na(opt$genes) ) {

  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript summariseMAFsGenes.R --maf_dir /data --maf_files PACA-AU.icgc.maf,PACA-CA.icgc.maf --cohorts ICGC-PACA-AU,ICGC-PACA-CA --genes KRAS,SMAD4,TP53,CDKN2A,ARID1A,BRCA1,BRCA2 --out_dir MAF_summary_genes\n\n")

  q()
} else if ( length(opt$maf_files) != length(opt$cohorts) ) {

  cat("\nMake sure that the number of cohorts names match the number of queried MAF files\n\n")

  q()
} else if ( length(opt$cohorts) < 2 ) {

   cat("\nMake sure that the number of cohorts names match the number of queried MAF files\n\n")

   q()
 }

##### Write the results into folder "MAF_summary" if no output directory is specified
if ( is.na(opt$out_dir) ) {
	opt$out_dir <- "MAF_summary_genes"
}

##### Pass the user-defined argumentas to the SVbezierPlot R markdown script and run the analysis
rmarkdown::render(input = "summariseMAFsGenes.Rmd", output_dir = paste(opt$maf_dir, opt$out_dir, "Report", sep = "/"), params = list(mafDir = opt$maf_dir, mafFiles = opt$maf_files, cohorts = opt$cohorts, genes = opt$genes, outDir = opt$out_dir))

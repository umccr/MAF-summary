################################################################################
#
#   Description: Script summarising and visualising multiple MAF files using maftools R package ( https://bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html ). This script catches the arguments from the command line and passes them to the summariseMAFs.Rmd script to produce the report, generate set of plots and excel spreadsheets summarising each MAF file.
#   NOTE: Each MAF file needs to contain the "Tumor_Sample_Barcode" column.
#
#   Command line use example: Rscript summariseMAFs.R --maf_dir /data --maf_files PACA-AU.icgc.simple_somatic_mutation.maf,PACA-CA.icgc.simple_somatic_mutation.maf --cohorts ICGC-PACA-AU,ICGC-PACA-CA --out_dir MAF_summary
#
#   maf_dir:      Directory with MAF files
#   maf_files:    List of MAF files to be processed. Each file name is expected to be separated by comma
#   cohorts:      Desired names of each cohort. The names are expected to be in the same order as provided MAF files and should be separated by comma
#   out_dir:      Output directory. If no output directory is specified the results will be saved in folder "MAF_summary"
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
  make_option(c("-o", "--out_dir"), action="store", default=NA, type='character',
              help="Output directory")
)

opt <- parse_args(OptionParser(option_list=option_list))

##### Read in argument from command line and check if all were provide by the user
if (is.na(opt$maf_dir) || is.na(opt$maf_files) || is.na(opt$cohorts) ) {

  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript summariseMAFs.R --maf_dir \"/data\" \"PACA-AU.icgc.maf,PACA-CA.icgc.maf\" \"ICGC-PACA-AU,ICGC-PACA-CA\" \"MAF_summary\"\n\n")

  q()
}

maf.dir <- opt$maf_dir
maf.files <- opt$maf_files
cohorts.list <- opt$cohorts
out.dir <- opt$out_dir

##### Write the results into folder "MAF_summary" if no output directory is specified
if ( is.na(out.dir) ) {
	out.dir <- "MAF_summary"
}

##### Pass the user-defined argumentas to the SVbezierPlot R markdown script and run the analysis
rmarkdown::render(input = "summariseMAFs.Rmd", params = list(mafDir = maf.dir, mafFiles = maf.files,  cohorts = cohorts.list, outDir = out.dir))

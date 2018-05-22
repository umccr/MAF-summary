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
#	  Description: Script summarising and visualising multiple MAF files using maftools R package ( https://bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html ).
#   NOTE: Each MAF file needs to contain the "Tumor_Sample_Barcode" column.
#
#   Command line use example: Rscript summariseMAFs.R --maf_dir /data --maf_files PACA-AU.icgc.simple_somatic_mutation.maf,PACA-CA.icgc.simple_somatic_mutation.maf --cohorts ICGC-PACA-AU,ICGC-PACA-CA --out_dir MAF_summary
#
#   maf_dir:      Directory with MAF files
#   maf_files:    List of MAF files to be processed. Each file name is expected to be separated by comma
#   cohorts:      Desired names of each cohort. The names are expected to be in the same order as provided MAF files and should be separated by comma
#	  out_dir:      Output directory. If no output directory is specified the results will be saved in folder "MAF_summary"
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
option_list = list(
  make_option(c("-d", "--maf_dir"), action="store", default=NA, type='character',
              help="Directory with MAF files"),
  make_option(c("-m", "--maf_files"), action="store", default=NA, type='character',
              help="List of MAF files to be processed"),
  make_option(c("-c", "--cohorts"), action="store", default=NA, type='character',
              help="Desired names of each cohort"),
  make_option(c("-o", "--out_dir"), action="store", default=NA, type='character',
              help="Output directory")
)

opt = parse_args(OptionParser(option_list=option_list))

##### Read in argument from command line and check if all were provide by the user
if (is.na(opt$maf_dir) || is.na(opt$maf_files) || is.na(opt$cohorts) ) {

  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript summariseMAFs.R --maf_dir \"/data\" \"PACA-AU.icgc.maf,PACA-CA.icgc.maf\" \"ICGC-PACA-AU,ICGC-PACA-CA\" \"MAF_summary\"\n\n")

  q()
}

mafDir <- opt$maf_dir

mafFiles <- opt$maf_files
mafFiles = gsub("\\s","", mafFiles)
mafFiles =  unlist(strsplit(mafFiles, split=',', fixed=TRUE))

cohorts <- opt$cohorts
cohorts = gsub("\\s","", cohorts)
cohorts = unlist(strsplit(cohorts, split=',', fixed=TRUE))

outDir <- opt$out_dir

##### Write the results into folder "MAF_summary" if no output directory is specified
if ( is.na(outDir) ) {
	outDir = "MAF_summary"
}


#===============================================================================
#    Main
#===============================================================================

##### Go to the MAF files directory
setwd(mafDir)

##### Read MAF files and put associated infop into a list
mafInfo <- vector("list", length(mafFiles))

for ( i in 1:length(mafFiles) ) {
  mafInfo[[i]] = read.maf(maf = mafFiles[i])
}

#===============================================================================
#    Summarising MAF files
#===============================================================================

##### Create directory for output files
if ( !file.exists(outDir) ){
  dir.create(outDir)
  cat(paste("\nOutput files will be saved in \"", outDir, "\" folder\n\n", sep=""))
  setwd(outDir)
} else {
  cat(paste("\nDirectory \"", outDir, "\" already exists! The output files will be saved there.\n\n", sep=""))
  setwd(outDir)
}

##### Write samples summary into a file
if ( !file.exists("MAF_sample_summary.xlsx") ){
  for ( i in 1:length(mafFiles) ) {
    write.xlsx(getSampleSummary(mafInfo[[i]]), file="MAF_sample_summary.xlsx", sheetName=cohorts[i], row.names=FALSE,  append=TRUE)
  }
} else {
  cat(paste("\nFile \"MAF_sample_summary.xlsx\" already exists in", mafDir, "!\n\n", sep=" "))
}

##### Write gene summary into a file
if ( !file.exists("MAF_gene_summary.xlsx") ){
  for ( i in 1:length(mafFiles) ) {
    write.xlsx(getGeneSummary(mafInfo[[i]]), file="MAF_gene_summary.xlsx", sheetName=cohorts[i], row.names=FALSE,  append=TRUE)
  }
} else {
  cat(paste("\nFile \"MAF_gene_summary.xlsx\" already exists in", mafDir, "!\n\n", sep=" "))
}

##### Get all fields in MAF files
if ( !file.exists("MAF_fields.xlsx") ){
  for ( i in 1:length(mafFiles) ) {
    write.xlsx(getFields(mafInfo[[i]]), file="MAF_fields.xlsx", sheetName=cohorts[i], row.names=FALSE,  append=TRUE, col.names=FALSE)
  }
} else {
  cat(paste("\nFile \"MAF_fields.xlsx\" already exists in", mafDir, "!\n\n", sep=" "))
}

##### Write overall summary into a file
if ( !file.exists("MAF_summary.xlsx") ){
  for ( i in 1:length(mafFiles) ) {
    write.xlsx(mafInfo[[i]]@summary, file="MAF_summary.xlsx", sheetName=cohorts[i], row.names=FALSE,  append=TRUE)
  }
} else {
  cat(paste("\nFile \"MAF_summary.xlsx\" already exists in", mafDir, "!\n\n", sep=" "))
}


#===============================================================================
#    Visualisation
#===============================================================================

###### Generate separate file with plots for each cohort
for ( i in 1:length(mafFiles) ) {

  cat(paste("\nGenerating plots for", cohorts[i], "cohort...\n\n", sep=" "))

  pdf(file = paste("MAF_summary_", cohorts[i], ".pdf", sep = ""))

  ##### Plotting MAF summary
  par(mar=c(4,4,2,0.5), oma=c(1.5,2,2,1))
  plotmafSummary(maf = mafInfo[[i]], rmOutlier = TRUE, addStat = 'median', dashboard = TRUE, titvRaw = FALSE)
  mtext("MAF summary", outer=TRUE,  cex=1, line=-0.5)

  ##### Drawing oncoplots for the top 10 genes in each cohort
  plot.new()
  par(mar=c(4,4,2,0.5), oma=c(1.5,2,2,1))
  oncoplot(maf = mafInfo[[i]], top = 10, fontSize = 12)

  ##### Drawing distribution plots of the transitions and transversions
  titv.info = titv(maf = mafInfo[[i]], plot = FALSE, useSyn = TRUE)

  plotTiTv(res = titv.info)
  mtext("Transition and transversions distribution", outer=TRUE,  cex=1, line=-1.5)
  ##### Write per-sample transitions and transversions distribution into a file

  write.xlsx(titv.info$fraction.contribution, file="MAF_summary_titv.xlsx", sheetName=paste0(cohorts[i], " (fraction)"), row.names=FALSE,  append=TRUE)
  write.xlsx(titv.info$raw.counts, file="MAF_summary_titv.xlsx", sheetName=paste0(cohorts[i], " (count)"), row.names=FALSE,  append=TRUE)
  write.xlsx(titv.info$TiTv.fractions, file="MAF_summary_titv.xlsx", sheetName=paste0(cohorts[i], " (TiTv fractions)"), row.names=FALSE,  append=TRUE)

  ##### Compare mutation load against TCGA cohorts
  tcgaCompare(maf = mafInfo[[i]], cohortName = cohorts[i])
  mtext("Mutation load in TCGA cohorts", outer=TRUE,  cex=1, line=-0.5)

  dev.off()
}


##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

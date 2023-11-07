################################################################################
#
#   File name: MAFsamplesRename.R
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
#   Description: Script for renaming sample names (as shown MAF "Tumor_Sample_Barcode" field) based on a file listing names substitutions.
#
#   Command line use example: Rscript MAFsamplesRename.R --maf_file simple_somatic_mutation.open.PACA-AU.maf --names_file simple_somatic_mutation.open.PACA-AU_samples_rename.txt --output simple_somatic_mutation.open.PACA-AU_samples_renamed.maf
#
#   maf_file:     MAF file to be processed
#   names_file:   Name and path to a file listing samples to be renamed. The first column is expected to contain sample names (as shown MAF "Tumor_Sample_Barcode" field) to be changed and the second columns is expected to contain the corresponding name to be used instead
#   output:       Name for the output MAF file. If no output file name is specified the output will have the same name as the input maf_file with suffix "_samples_renamed.maf"
#
################################################################################

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()


#===============================================================================
#    Functions
#===============================================================================

##### Prepare object to write into a file
prepare2write <- function (x) {

	x2write <- cbind(rownames(x), x)
    colnames(x2write) <- c("",colnames(x))
	return(x2write)
}


#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(optparse))
suppressMessages(library(maftools))
suppressMessages(library(tibble))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list <- list(
  make_option(c("-m", "--maf_file"), action="store", default=NA, type='character',
              help="MAF file to be proccessed"),
  make_option(c("-s", "--names_file"), action="store", default=NA, type='character',
              help="Name and path to a file listing samples to be renamed"),
  make_option(c("-o", "--output"), action="store", default=NA, type='character',
              help="Name for the output MAF file")
)

opt <- parse_args(OptionParser(option_list=option_list))


##### Check if the required arguments are provided
if ( is.na(opt$maf_file) || is.na(opt$names_file)  ) {

  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript MAFsamplesRename.R --maf_file simple_somatic_mutation.open.PACA-AU.maf --names_file simple_somatic_mutation.open.PACA-AU_samples_rename.txt --output simple_somatic_mutation.open.PACA-AU_samples_renamed.maf\n\n")

  q()
}


#===============================================================================
#    Main
#===============================================================================

##### Check if the input file exists
if ( !file.exists(opt$maf_file) ){

  cat(paste0("\nFile \"", opt$maf_file, "\" does not exist!\n\n"))
  q()
}

##### Specify output file name if not pre-defined
if ( is.na(opt$output) ) {
  
  opt$output <- paste0(opt$maf_file, "_samples_renamed.maf")
}

cat("\nReading MAF file...\n\n")

##### Read MAF file
mafInfo = maftools::read.maf(maf = opt$maf_file, verbose = FALSE)

##### Specify samples to be renamed. The first column is expected to contain sample names (as shown MAF "Tumor_Sample_Barcode" field) to be changed and the second columns is expected to contain the corresponding name to be used instead
samples2rename <- read.table(opt$names_file, sep="\t", as.is=TRUE, header=FALSE, row.names=NULL)

##### Remove duplicated rows and prepare the data for merging with MAF data
samples2rename <- dplyr::distinct(samples2rename)
colnames(samples2rename)[1] <- "Tumor_Sample_Barcode"

##### Extract data from MAF
MAF.sub <- maftools::subsetMaf(maf = mafInfo, mafObj = FALSE, includeSyn = TRUE, tsb = samples2rename$Tumor_Sample_Barcode)

##### The subsetMaf adds a column with the MAF genes order. Use it to reorder the new MAF and remove that column once done
if ( length(MAF.sub[ ,1]$V1) > 0 ) {
  MAF.sub <- MAF.sub[ order(MAF.sub[ ,1]$V1), ]
  MAF.sub <- MAF.sub[ , -1]
}

##### Get the "Tumor_Sample_Barcode" column index
Tumor_Sample_Barcode.ixd <- match("Tumor_Sample_Barcode", names(MAF.sub))

##### Keep the "Tumor_Sample_Barcode" field copy and get its index
MAF.sub <- add_column(MAF.sub, Tumor_Sample_Barcode.orig = MAF.sub$Tumor_Sample_Barcode, .after = Tumor_Sample_Barcode.ixd)

##### Record the MAF columns order
MAF.cols <- names(MAF.sub)

##### Merge the MAF data with data frame containing samples substitution info using the "Tumor_Sample_Barcode" field as common column
cat("\nSubstituting sample names based on \"Tumor_Sample_Barcode\" field in MAF file...\n\n")
MAF.sub.merged <- merge(MAF.sub, samples2rename, by = "Tumor_Sample_Barcode", all.x = TRUE, all.y = FALSE, sort = FALSE)

MAF.sub.merged$Tumor_Sample_Barcode <- MAF.sub.merged$V2

##### Reorder columns according to the original MAF file
MAF.sub.merged <- as.data.frame(MAF.sub.merged)
MAF.sub.merged <- MAF.sub.merged[, MAF.cols]

##### Write the output MAF into a file
write.table(prepare2write(MAF.sub.merged), file=opt$output, sep="\t", row.names=FALSE, quote = FALSE)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

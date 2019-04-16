################################################################################
#
#   File name: mergeMAFs.R
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
#   Description: Script merging multiple MAF files using merge_mafs function in maftools R package ( https://bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html, https://rdrr.io/github/PoisonAlien/maftools/man/merge_mafs.html ).
#   NOTE: Each MAF file needs to contain the "Tumor_Sample_Barcode" column.
#
#   Command line use example: Rscript mergeMAFs.R --maf_dir /data --maf_files simple_somatic_mutation.open.PACA-AU.maf,simple_somatic_mutation.open.PACA-CA.maf --maf_fields All --output icgc.simple_somatic_mutation.merged.maf
#
#   maf_dir:      Directory with MAF files to be merged
#   maf_files:    List of MAF files to be merged. Each file name is expected to be separated by comma
#   maf_fields:   Fields to be kept in merged MAF. Options available: "All" (default), "Nonredundant", and "Basic"
#   output:       Name for the output merged MAF file. If no output file name is specified the output will be saved as "merged.maf"
#
################################################################################

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()


#===============================================================================
#    Functions
#===============================================================================

##### Create 'not in' operator
"%!in%" <- function(x,table) match(x,table, nomatch = 0) == 0

##### Prepare object to write into a file
prepare2write <- function (x) {

	x2write <- cbind(rownames(x), x)
    colnames(x2write) <- c("",colnames(x))
	return(x2write)
}

##### Merge multiple maf files into a single MAF (from maftools package)
merge_mafs = function(mafs, MAFobj = FALSE, ...){
  
  maf = lapply(mafs, data.table::fread, stringsAsFactors = FALSE, fill = TRUE,
               showProgress = TRUE, header = TRUE, skip = "Hugo_Symbol")
  names(maf) = gsub(pattern = "\\.maf$", replacement = "", x = basename(path = mafs), ignore.case = TRUE)
  maf = data.table::rbindlist(l = maf, fill = TRUE, idcol = "sample_id", use.names = TRUE)
  
  if(MAFobj){
    maf = read.maf(maf = maf, ...)
  }
  
  maf
}

#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(optparse))
suppressMessages(library(maftools))


#===============================================================================
#    Catching the arguments
#===============================================================================
option_list <- list(
  make_option(c("-d", "--maf_dir"), action="store", default=NA, type='character',
              help="Directory with MAF files"),
  make_option(c("-m", "--maf_files"), action="store", default=NA, type='character',
              help="List of MAF files to be processed"),
  make_option(c("-f", "--maf_fields"), action="store", default=NA, type='character',
              help="Fields to be kept in merged MAF"),
  make_option(c("-o", "--output"), action="store", default=NA, type='character',
              help="Name for the output merged MAF file")
)

opt <- parse_args(OptionParser(option_list=option_list))

##### Collect MAF files
opt$maf_files <- gsub("\\s","", opt$maf_files)

##### Read in argument from command line and check if all were provide by the user
if (is.na(opt$maf_dir) || is.na(opt$maf_files) ) {
  
  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript summariseMAFs.R --maf_dir /data --maf_files simple_somatic_mutation.open.PACA-AU.maf,simple_somatic_mutation.open.PACA-CA.maf --output icgc.simple_somatic_mutation.merged.maf\n\n")
  q()
}

##### Set default parameters
if ( tolower(opt$maf_fields) == "all" || tolower(opt$maf_fields) == "nonredundant" || tolower(opt$maf_fields) == "basic" ) {
  
  opt$maf_fields <- tolower(opt$maf_fields)
  
} else {
  cat(paste0("\nWrong \"maf_fields\" parameter: ", opt$maf_fields, ". Choose \"all\", \"nonredundant\" or \"basic\" option.\n\n"))
  q()
}
  
#===============================================================================
#    Main
#===============================================================================

##### Split the string of MAF files and put them into a vector
mafFiles <- unlist(strsplit(opt$maf_files, split=',', fixed=TRUE))
mafFiles <- paste(opt$maf_dir, mafFiles, sep="/")

##### Check if more than 1 MAF is provided
if ( length(mafFiles) < 2 ) {
  
  cat(paste0("\nOnly one MAF file (\"", mafFiles[i], "\") was provided!\n\n"))
  q()
}

##### Check if the input files exist
for ( i in 1:length(mafFiles) ) {
  if ( !file.exists(mafFiles[i]) ){
  
    cat(paste0("\nFile \"", mafFiles[i], "\" does not exist!\n\n"))
    q()
  }
}

##### Specify output file name if not pre-defined
if ( is.na(opt$output) ) {
  
  opt$output <- paste(opt$maf_dir, "merged.maf", sep="/")
  
} else {
  opt$output <- paste(opt$maf_dir, opt$output, sep="/")
}

cat("\nReading MAF files...\n\n")

##### Read MAF files and put associated info into a list
##### Create a list to store MAF info for individual datasets
mafInfo <- vector("list", length(mafFiles))
mafFields <- NULL

for ( i in 1:length(mafFiles) ) {
  
  cat(paste0("\nProcessing MAF: ", mafFiles[i],"...\n\n"))
  
  mafInfo[[i]] <- maftools::read.maf(maf = mafFiles[i], verbose = FALSE)
  mafFields <- c(mafFields, names(mafInfo[[i]]@data))
}

mafs.merged <- merge_mafs(mafFiles, MAFobj = FALSE)

##### Define required MAF fields
mafFields.required <- c("Hugo_Symbol", "Chromosome", "Start_Position", "End_Position", "Reference_Allele", "Tumor_Seq_Allele2", "Variant_Classification", "Variant_Type", "Tumor_Sample_Barcode")
mafFields.merged <- c("sample_id", "NCBI_Build")
mafFields.aa_changes <- c("HGVSp_Short", "aa_mutation")

mafFields.basic <- c(mafFields.required, mafFields.merged, mafFields.aa_changes)

##### Keep only basic MAF fields
if ( opt$maf_fields == "basic" ) {
  
  mafFields2rm <- unique(mafFields)[ unique(mafFields) %!in% mafFields.basic ]
  
  if ( length(mafFields2rm) > 1 ) {
    
    mafs.merged <- mafs.merged[, c(mafFields2rm):=NULL]
  }

##### Keep only non-redundant columns, i.e. those which are present only in one dataset
} else if ( opt$maf_fields == "nonredundant" ) {

  mafFields2rm <- unique(mafFields)[ table(mafFields) < 2 ]
  mafFields2rm <- mafFields2rm[ mafFields2rm %!in% mafFields.basic ]
  
  if ( length(mafFields2rm) > 1 ) {
    
    mafs.merged <- mafs.merged[, c(mafFields2rm):=NULL]
  }

}

##### Make sure that only the Build number is passed to the "
mafs.merged$NCBI_Build <- gsub("[^0-9.]", "", mafs.merged$NCBI_Build) 

##### Write subsetted MAF into a file
write.table(prepare2write(mafs.merged), file=opt$output, sep="\t", row.names=FALSE, quote = FALSE)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

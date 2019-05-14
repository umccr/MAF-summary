################################################################################
#
#   File name: icgcMutationToMAF.R
#
#   Authors: Jacek Marzec ( jacek.marzec@unimelb.edu.au )
#
#   University of Melbourne Centre for Cancer Research,
#   Victorian Comprehensive Cancer Centre
#   305 Grattan St, Melbourne VIC 3000
#
################################################################################

################################################################################
#
#	  Description: Script converting ICGC Simple Somatic Mutation Format file to MAF file using maftools R package ( https://bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html ).
#
#	  Command line use example: Rscript icgcMutationToMAF.R --icgc_file PACA-AU.icgc.simple_somatic_mutation.tsv --removeDuplicatedVariants TRUE --output PACA-AU.icgc.simple_somatic_mutation.maf
#
#	  icgc_file:		ICGC Simple Somatic Mutation Format file to be converted
#	  remove_duplicated_variants:		Remove repeated variants in a particuar sample, mapped to multiple transcripts of same gene? Defulat value is "FALSE"
#	  output:		The output file name. If no output file name is specified the file extension will be changed to ".maf"
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

suppressMessages(library(maftools))
suppressMessages(library(optparse))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
  make_option(c("-i", "--icgc_file"), action="store", default=NA, type='character',
              help="ICGC Simple Somatic Mutation Format file to be converted"),
  make_option(c("-r", "--remove_duplicated_variants"), action="store", default=NA, type='character',
              help="Remove repeated variants in a particuar sample, mapped to multiple transcripts of same gene?"),
  make_option(c("-o", "--output"), action="store", default=NA, type='character',
              help="Output file name")
)

opt = parse_args(OptionParser(option_list=option_list))

output.maf <- opt$output
input.icgc <- opt$icgc_file
remove.duplicated.variants <- opt$remove_duplicated_variants

##### Change the file extension to .maf if output file name is not specified
if ( is.na(output.maf) ) {
	output.maf = unlist(strsplit(input.icgc, split='.', fixed=TRUE))
	output.maf = paste0(paste(output.maf[-length(output.maf)], collapse = '.'), ".maf")
}

##### Set defualt paramters
if ( is.na(remove.duplicated.variants) ) {
  remove.duplicated.variants = FALSE
}

##### Check input paramters
if ( tolower(remove.duplicated.variants) != "true" && tolower(remove.duplicated.variants) != "false"  ) {
  cat("Make sure that the \"--removeDuplicatedVariants\" parameter is set to \"TRUE\" or \"FALSE\"!")
}

#===============================================================================
#    Main
#===============================================================================

##### Read ICGC Simple Somatic Mutation Format file and convert Ensemble Gene IDs into HGNC gene symbols
##### This step removes repeated variants as duplicated entries (removeDuplicatedVariants = TRUE)
icgc.maf <- icgcSimpleMutationToMAF(icgc = input.icgc, addHugoSymbol = TRUE, removeDuplicatedVariants = remove.duplicated.variants)

##### Write converted MAF file into a file
write.table(prepare2write(icgc.maf), file = output.maf, sep = "\t", row.names = FALSE)

##### Print session info
devtools::session_info()

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

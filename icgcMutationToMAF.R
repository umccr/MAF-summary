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
#	  Command line use example: R --file=./icgcMutationToMAF.R --args "PACA-AU.icgc.simple_somatic_mutation.tsv" "PACA-AU.icgc.simple_somatic_mutation.maf"
#
#	  First arg:     ICGC Simple Somatic Mutation Format file to be converted.
#	  Second arg:    The output file name.
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

library(maftools)

#===============================================================================
#    Main
#===============================================================================

args <- commandArgs()

input.icgc = args[4]
output.maf = args[5]

##### Read ICGC Simple Somatic Mutation Format file and convert Ensemble Gene IDs into HGNC gene symbols
##### This step removes repeated variants as duplicated entries (removeDuplicatedVariants = TRUE)
icgc.maf <- icgcSimpleMutationToMAF(icgc = input.icgc, addHugoSymbol = TRUE, removeDuplicatedVariants = TRUE)

##### Write converted MAF file into a file
write.table(prepare2write(icgc.maf), file = output.maf, sep = "\t", row.names = FALSE)


##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

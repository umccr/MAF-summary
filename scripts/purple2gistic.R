################################################################################
#
#   File name: purple2gistic.R
#
#   Authors: Jacek Marzec ( jacek.marzec@unimelb.edu.au )
#
#   University of Melbourne Centre for Cancer Research,
#   Victorian Comprehensive Cancer Centre
#   305 Grattan St, Melbourne, VIC 3000
#
#   Acknowledgements: the code was adapted from Andrew Pattison
#
################################################################################

################################################################################
#
#   Description: Script combining and converting Purple (https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator) output into GISTIC (https://www.genepattern.org/modules/docs/GISTIC_2.0) compatible input.
#
#   Command line use example: Rscript purple2gistic.R --purple_files cnvs.txt --output cnv_combined
#
#   purple_files: Full path and name of a file listing purple ".purple.cnv.somatic.tsv" output files to combine
#   output:       Full path and name for the output folder
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
suppressMessages(library(tidyverse))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list <- list(
  make_option(c("-i", "--purple_files"), action="store", default=NA, type='character',
              help="Full path and name of a file listing purple output files to combine"),
  make_option(c("-o", "--output"), action="store", default=NA, type='character',
              help="Full path and name for the output folder")
)

opt <- parse_args(OptionParser(option_list=option_list))


##### Check if the required arguments are provided
if ( is.na(opt$purple_files) || is.na(opt$output) ) {
  
  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript purple2gistic.R --purple_files cnvs.txt --output cnv_combined\n\n")
  
  q()
}

##### Check if the directory for the output files exists
if ( !file.exists(opt$output) ) {
  dir.create(opt$output, recursive=TRUE)
}

#===============================================================================
#    Main
#===============================================================================

##### Check if the input file exists
if ( !file.exists(opt$purple_files) ){
  
  cat(paste0("\nFile \"", opt$purple_files, "\" does not exist!\n\n"))
  q()
  
}

##### read in a file with purple cnv files 
purple_files <- read.table(opt$purple_files, sep="\t", as.is=TRUE, header=FALSE, row.names = NULL)
all_outputs <- list()

##### Read in purple cnv files
for (i in 1:nrow(purple_files)){
  
  sample <- gsub(".*/", "", purple_files[i,])
  sample <- gsub(".purple.cnv.somatic.tsv", "", sample)
  purple_out <- read_tsv(purple_files[i,], col_types = cols(.default = "c"))
  df <- data.frame(sample, purple_out, stringsAsFactors = F)
  all_outputs[[i]] <- df
}

##### Combined all purple outputs and save as a file
combined <- bind_rows(all_outputs)
write_csv(combined, paste(opt$output, "/cnv_combined.csv"))


##### Make a file for gistic from the PURPLE outputs. 
# Gisitc input format 
# Sample	Chrom	Start	Stop	#Mark	Seg.CN
#   S1	   1	   61735	77473	10	-0.1234

##### Make a .seg file
gistic_format <- combined %>%
  
  # Set number of marks to BafCount. That would be equivalent No. of spots on a copy number array
  dplyr::select(Sample = sample, Chrom = chromosome, Start= start, Stop = end, `#Mark` = bafCount, Seg.CN = copyNumber) %>%
  dplyr::filter(Seg.CN >0) %>%
  
  # Center around 0 for GISTIC
  mutate(Seg.CN = log2(as.numeric(Seg.CN))-1)

##### Save converted data inta a seg file
write_tsv(gistic_format, paste(opt$output, "/cnv_combined.seg"))

##### Draw a histogram of values. Should be centered around 0
pdf(paste(opt$output, "/cnv_combined.pdf"), width=8, height=5)
hist(gistic_format$Seg.CN,breaks = 1000)
invisible(dev.off())

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

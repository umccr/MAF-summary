################################################################################
#
#   File name: subsetMAF.R
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
#   Description: Script for subsetting user-specified MAF file using function subsetMaf from maftools R package ( https://bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html ).
#
#   Command line use example: Rscript subsetMAF.R --maf_file simple_somatic_mutation.open.PACA-AU.maf --samples ICGC_PACA_AU_KRAS-wt_samples.txt --genes ICGC_PACA_AU_genes.txt  --var_class Missense_Mutation --output simple_somatic_mutation.open.PACA-AU_subset.maf
#
#   maf_file:     MAF file to be subsetted
#   samples (optional): Name and path to a file listing samples to be kept in the subsetted MAF. Sample names (as shown MAF "Tumor_Sample_Barcode" field) are expected to be separated by comma. Use "all" to keep all samples
#   genes (optional): Name and path to a file listing genes to be kept in the subsetted MAF. Gene symbols are expected to be separated by comma. Use "all" to keep all genes
#   var_class (optional): Classification of variants to be kept in the subsetted MAF. Available variants types are: Frame_Shift_Del, Frame_Shift_Ins, In_Frame_Del, In_Frame_Ins, Missense_Mutation, Nonsense_Mutation, Silent, Splice_Site, Translation_Start_Site, Nonstop_Mutation, 3'UTR, 3'Flank, 5'UTR, 5'Flank, IGR, Intron, RNA, Targeted_Region, De_novo_Start_InFrame, De_novo_Start_OutOfFrame, Splice_Region
#   output:       Name for the output subsetted MAF. If no output file name is specified the output will have the same name as the input maf_file with suffix "_subset.maf"
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
suppressMessages(library(maftools))


#===============================================================================
#    Catching the arguments
#===============================================================================
option_list <- list(
  make_option(c("-m", "--maf_file"), action="store", default=NA, type='character',
              help="MAF file to be subsetted"),
  make_option(c("-s", "--samples"), action="store", default=NA, type='character',
              help="Name and path to a file listing samples to be kept in the subsetted MAF"),
  make_option(c("-g", "--genes"), action="store", default=NA, type='character',
              help="Name and path to a file listing genes to be kept in the subsetted MAF"),
  make_option(c("-v", "--var_class"), action="store", default=NA, type='character',
              help="Classificiation of variants to be kept in the subsetted MAF"),
  make_option(c("-o", "--output"), action="store", default=NA, type='character',
              help="Name for the output subsetted MAF")
)

opt <- parse_args(OptionParser(option_list=option_list))


##### Check if the required arguments are provided
if ( is.na(opt$maf_file)  ) {

  cat("\nPlease type in required arguments!\n\n")
  cat("\ncommand example:\n\nRscript summariseMAFs.R simple_somatic_mutation.open.PACA-AU.maf --samples ICGC_PACA_AU_KRAS-wt_samples.txt --genes ICGC_PACA_AU_genes.txt  --output simple_somatic_mutation.open.PACA-AU_subset.maf\n\n")

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
  
  opt$output <- paste0(opt$maf_file, "_subset.maf")
}

cat("\nReading MAF file...\n\n")

##### Read MAF file
mafInfo = maftools::read.maf(maf = opt$maf_file, verbose = FALSE)

##### Specify samples to keep in the subsetted MAF (if sepcified). NOTE, if there are multiple column then only the first one is taken into account
if ( !is.na(opt$samples) ) {
  
  sample2keep <- as.vector(read.table(opt$samples, sep="\t", as.is=TRUE, header=FALSE, row.names=NULL)[,1])
  
##### Otherwise keep all samples
} else {
  sample2keep <- NULL
}

##### Specify genes to keep in the subsetted MAF (if sepcified) NOTE, if there are multiple column then only the first one is taken into account
if ( !is.na(opt$genes) ) {
  
  genes2keep <- as.vector(read.table(opt$genes, sep="\t", as.is=TRUE, header=FALSE, row.names=NULL)[,1])
  
  ##### Otherwise keep all genes
} else {
  genes2keep <- NULL
}

##### Specify classification of variants to keep in the subsetted MAF (if sepcified)
if ( !is.na(opt$var_class) ) {
  
  vars2keep <- unlist(strsplit(opt$var_class, split=',', fixed=TRUE))

  ##### Add variants of each type into the MAF
  if ( length(vars2keep) > 1 ) {
    
    MAF.sub <- NULL
    
    for ( i in 1:length(vars2keep) ) {
      
      var2keep <- paste0( "Variant_Classification == \"", vars2keep[i], "\"")
      MAF.sub <- rbind(MAF.sub, subsetMaf(maf = mafInfo, tsb = sample2keep, genes = genes2keep, fields = NULL, query = var2keep, mafObj = FALSE, includeSyn = TRUE))
      
    }
    
  } else {
    var2keep <- paste0( "Variant_Classification == \"", opt$var_class, "\"")
    
    ##### Extract required data from MAF
    MAF.sub <- subsetMaf(maf = mafInfo, tsb = sample2keep, genes = genes2keep, fields = NULL, query = var2keep, mafObj = FALSE, includeSyn = TRUE)
  }
  
##### Otherwise keep all variants
} else {
  MAF.sub <- subsetMaf(maf = mafInfo, tsb = sample2keep, genes = genes2keep, fields = NULL, query = NULL, mafObj = FALSE, includeSyn = TRUE)
}

##### The subsetMaf adds a column with the MAF genes order. Use it to reorder the new MAF and remove that column once done
if ( length(MAF.sub[ ,1]$V1) > 0 ) {
  MAF.sub <- MAF.sub[ order(MAF.sub[ ,1]$V1), ]
  MAF.sub <- MAF.sub[ , -1]
}

##### Write subsetted MAF into a file
write.table(MAF.sub, file=opt$output, sep="\t", row.names=FALSE, quote = FALSE)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

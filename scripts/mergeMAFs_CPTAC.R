# Script to merger CPTAC data
# https://portal.gdc.cancer.gov/repository?facetTab=cases&filters=%7B%22op%22%3A%22and%22%2C%22content%22%3A%5B%7B%22op%22%3A%22in%22%2C%22content%22%3A%7B%22field%22%3A%22cases.primary_site%22%2C%22value%22%3A%5B%22pancreas%22%5D%7D%7D%2C%7B%22op%22%3A%22in%22%2C%22content%22%3A%7B%22field%22%3A%22cases.project.program.name%22%2C%22value%22%3A%5B%22CPTAC%22%2C%22TCGA%22%5D%7D%7D%2C%7B%22op%22%3A%22in%22%2C%22content%22%3A%7B%22field%22%3A%22files.access%22%2C%22value%22%3A%5B%22open%22%5D%7D%7D%5D%7D&searchTableTab=cases
# Trying the approach as suggested here https://github.com/PoisonAlien/maftools/issues/851

# Load libraries
suppressMessages(library(maftools))
suppressMessages(library(data.table))
suppressMessages(library(here))

# Create 'not in' operator
"%!in%" <- function(x,table) match(x,table, nomatch = 0) == 0

# Prepare object to write into a file
prepare2write <- function (x) {

  x2write <- cbind(rownames(x), x)
  colnames(x2write) <- c("",colnames(x))
  return(x2write)
}

file_list <- list.files(path = here::here("../data/combined_cptac_pdac_atlas"), pattern="*.maf")
# skip was added for cptac data that had first 7 rows as header
maf_list = lapply(file_list, function(x) data.table::fread(x, fill=TRUE, skip=7))
names(maf_list) = gsub(pattern = "\\.maf$", replacement = "", x = file_list, ignore.case = TRUE)
maf = rbindlist(maf_list, fill=TRUE, idcol = "sample_id", use.names = TRUE)
mafs.merged = read.maf(maf)

# Define required MAF fields
mafFields.required <- c("Hugo_Symbol", "Chromosome", "Start_Position", "End_Position", "Reference_Allele", "Tumor_Seq_Allele2", "Variant_Classification", "Variant_Type", "Tumor_Sample_Barcode")
mafFields.merged <- c("sample_id", "NCBI_Build")
mafFields.aa_changes <- c("HGVSp_Short", "aa_mutation")
mafFields.basic <- c(mafFields.required, mafFields.merged, mafFields.aa_changes)

mafFields <- names(mafs.merged@data)
mafFields2rm <- unique(mafFields)[ unique(mafFields) %!in% mafFields.basic ]

if ( length(mafFields2rm) >= 1 ) {

  mafs.merged <- mafs.merged@data[, c(mafFields2rm):=NULL]
}

# Write merged data
write.table(prepare2write(mafs.merged), file = here::here("CPTAC/merged_paad_atlas_cptac.maf"), sep="\t", row.names=FALSE, quote = FALSE)

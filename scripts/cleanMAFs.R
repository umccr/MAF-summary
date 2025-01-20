list_path_MAF = list.files(path = "/Users/kanwals/UMCCR/research/data/pdac_driver_analysis/tmp", full.names = TRUE)

mafs = lapply(X = list_path_MAF, function(x){
  data.table::fread(file = x, sep = "\t")
})

mafs = data.table::rbindlist(l = mafs, use.names = TRUE, fill = TRUE)

maf_file = maftools::read.maf(maf = mafs)
write.mafSummary(maf_file, basename = "/Users/kanwals/UMCCR/research/data/pdac_driver_analysis/tmp/merged_liftedover_paad_atlas_cptac_rmhightmb_updateINS_rm_SA408066_SP69609_hmf")

maf <- read.table("merged_paad.maf", sep = "\t", header = TRUE, fill = TRUE, quote = "")
dim(maf)

to_remove <- c(
  "ACTN01020019T", "ACTN01020081T", "ACTN01020084T", "ACTN01020367T",
  "CORE01080045T", "CORE01080054T", "CPCT02010312TII", "CPCT02010577T",
  "CPCT02010589T", "CPCT02010688T", "CPCT02020219T", "CPCT02020248TII",
  "CPCT02020285T", "CPCT02020505T", "CPCT02020579T", "CPCT02020582T",
  "CPCT02020587T", "CPCT02030450T", "CPCT02030471T", "CPCT02040228T",
  "CPCT02050202T", "CPCT02060236T", "CPCT02070040T", "CPCT02070298T",
  "CPCT02080041T", "CPCT02080086T", "CPCT02080223T", "CPCT02110035T",
  "CPCT02130028T", "CPCT02130154T", "CPCT02170002T", "CPCT02170022T",
  "CPCT02230043T", "CPCT02290051T", "CPCT02290053T", "CPCT02300019T",
  "DRUP01050040T", "DRUP01050040TII", "WIDE01010006T", "WIDE01010051T",
  "WIDE01010994T", "WIDE01011138T", "WIDE01011190T"
)

maf_filtered <- maf[!maf$Tumor_Sample_Barcode %in% to_remove, ]

# check
dim(maf_filtered)

# find targeted samples (KRAS & MEN1 mutated)
samples_to_remove <- unique(maf_filtered$Tumor_Sample_Barcode[
  maf_filtered$Hugo_Symbol == "KRAS" &
    maf_filtered$Tumor_Sample_Barcode %in% maf_filtered$Tumor_Sample_Barcode[maf_filtered$Hugo_Symbol == "MEN1"]
])

# remove these samples
maf_filtered_men1 <- maf_filtered[!maf_filtered$Tumor_Sample_Barcode %in% samples_to_remove, ]

# check
dim(maf_filtered_men1)

write.table(maf_filtered_men1, file = "merged_paad_filtered_men1.maf", sep = "\t", quote = FALSE, row.names = FALSE)

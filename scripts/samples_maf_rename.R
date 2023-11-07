### This is a helper script to be used in conjuction with MAFsamplesRename.R for PDAC data analysis. 
### It lists files in a directory with a specific pattern and extracts patterns of interest. 
### For example for file named "SBJ04186__PRJ170117-somatic-PASS.maf", 'between_pattern' will be 
### "SBJ04186__PRJ170117" and 'after_pattern' will be "PRJ170117.

# Load libraries
library(here)

# Set the directory path and list files
directory_path <- here(("UMCCR/research/projects/PAAD_atlas/maf_analysis/data/out"))  # Replace with the actual path to your directory
files <- list.files(directory_path)

# Extract the desired patterns from the file names
between_pattern <- gsub("^(.*?)\\-somatic-PASS\\.maf", "\\1", files)
after_pattern <- gsub("^(.*?)__(.*?)\\-somatic-PASS\\.maf", "\\2", files)


# Create a data frame with the patterns
pattern_data <- data.frame(AfterPattern = after_pattern, BetweenPattern = between_pattern)

# Write the data frame to an output text file
write.table(pattern_data, file = here(("UMCCR/research/projects/PAAD_atlas/maf_analysis/data/out/priginal_replace.txt")), row.names = FALSE, col.names = TRUE, sep = "\t", quote = FALSE)
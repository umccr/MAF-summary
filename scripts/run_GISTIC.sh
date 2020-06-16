################################################################################
#
#  Acknowledgements: the code was adapted from Andrew Pattison
#
#  https://github.com/umccr/A5_GISTIC
#
################################################################################


###### Installation
# Download GISTIC
# http://portals.broadinstitute.org/cgi-bin/cancer/publications/pub_paper.cgi?mode=view&paper_id=216&p=t

# One need to install MATLAB
# Install MATLAB (included in GISTIC release)

cd gistic
tar zxf GISTIC_2_0_23.tar.gz 
cd MCR_Installer/
unzip MCRInstaller.zip
./install -mode silent -agreeToLicense yes -destinationFolder gistic/MATLAB_Compiler_Runtime/ 

# Run example
./run_gistic_example

# Add GISTIC to the PATH
vim ~/.bash_profile


################################################################################
##### Preferred options

# Define GISTIC folder
GIS_folder=/apps/gistic

# Define input/output directory
echo --- creating output directory ---
basedir=/data/CNVs_combined
mkdir -p $basedir

echo --- running GISTIC ---
# Input file definitions
segfile=$basedir/cnv_combined.seg

# GRCh37
#refgenefile=$GIS_folder/refgenefiles/hg19.mat

# GRCh38
refgenefile=$GIS_folder/refgenefiles/hg38.UCSC.add_miR.160920.refgene.mat

cd $GIS_folder

## call script that sets MCR environment and calls GISTIC executable
./gistic2 -b $basedir -seg $segfile -refgene $refgenefile -genegistic 1 -smallmem 0 -broad 1 -brlen 0.98 -conf 0.9 -armpeel 0 -savegene 1 -gcm extreme -rx 0 -qv_thresh 1 -twoside 1

# NOTE, "-qv_thresh" was set to "1" since we are interested in amplifications/deletions in all samples, not only in those that are recurrent across samples
# NOTE, create two-dimensional quadrant figure as part of a broad-level analysis ("-twoside") # NOTE, this sometimes throws an error, and then it needs to be set to "0"
# NOTE, "-armpeel" was set to 0 to use normal arbitrated peel-off

echo --- Completed ---
date

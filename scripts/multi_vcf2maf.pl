#!/usr/bin/perl
################################################################################
#
#   File name: multi_vcf2maf.pl
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
#	Description: Script for converting multiple VCF files into corresponding MAF files, which are then merged into one collective MAF file.
#
#	Command line use example: perl multi_vcf2maf.pl  -l /examples/example_vcf_list.txt  -e FALSE  -s /tools/vcf2maf.pl  -r /reference/GRCh37-lite.fa  -m /data/example.maf
#
#	-l / --vcf_list:    Full path with name of a file listing VCF files, along with corresponding directories, to be converted
#	-e / --exons:       Include exonic regions only? TRUE/T or FALSE/F (defualt)
#	-s / --v2m:         Full path to vcf2maf.pl script (https://github.com/mskcc/vcf2maf)
#	-r / --ref:         Reference FASTA file
#	-m / --maf_file:    Name of the merged MAF file to be created. It will be save in the folder with the file listing VCF files
#
################################################################################

use strict;
use warnings;
use List::MoreUtils qw(firstidx);

sub usage ();

#===============================================================================
#    Functions
#===============================================================================
 

#===============================================================================
#    Main
#===============================================================================

our @ARGV;
my $arg;
my $vcfList;
my $exons;
my $outMaf;
my $v2m;
my $ref;
my @dir;
my $dir;
my $vcfFile;
my $vcfFileGZ;
my $vepFile;
my $mafFile;
my $mafFiles = "";
my @mafInfo;
my $mafInfo;
my @varInfo;
my $exon_col = 0;
my $sampleName;
my $mafHeader;

while ($arg = shift) {
    if ($arg =~ /^-l$/ || $arg =~ /^--vcf_list/) {
        $vcfList = shift;
    } elsif ($arg =~ /^-e$/ || $arg =~ /^--exons/) {
        $exons = shift;
    } elsif ($arg =~ /^-m$/ || $arg =~ /^--maf_file$/) {
        $outMaf = shift;
    } elsif ($arg =~ /^-s$/ || $arg =~ /^--v2m$/) {
        $v2m = shift;
    } elsif ($arg =~ /^-r$/ || $arg =~ /^--ref$/) {
        $ref = shift;
    } elsif ($arg =~ /-h/ || $arg =~ /--help/) {
        usage ();
    }
}

##### Check the required paramters
if ($vcfList and $exons and $outMaf and $v2m and $ref) {
    
    ##### Extract the directory info for the final MAF file
    @dir = split('/', $vcfList);
    $dir = join('/', @dir[0 .. $#dir-1]);
    $outMaf = $dir . "/" . $outMaf;
    
    ##### Open the file listing input VCFs
    open (FILES_LIST, '<', $vcfList) or die "Could not open file '$vcfList' $!";
    
    ##### Loop thorough all VCF files listed in provided file
    while (my $record = <FILES_LIST>) {
        
        chomp $record;
        $record =~ s/"//g;
        
        ##### Put columns into an array
        my @info = split(/\t/, $record);
        
        ##### Extract names of listed VCFs
        $info[ 0 ] =~ s/\.gz$//g;
        $vcfFile = $info[ 0 ];
        
        ##### ... and check if they exist
        if ( $vcfFile =~ m/.*?\.vcf\.gz$/ || $vcfFile =~ m/.*?\.vcf$/ ) {
            
            ##### uncompress .gz VCFs
            $vcfFileGZ = $vcfFile . ".gz";
            
            if (-e $vcfFileGZ ) {

                system( "gunzip $vcfFileGZ" );         
            }
            
            ##### Once again make sure the uncompressed VCF file exists
            if (-e $vcfFile) {
                
                ##### Also prepare MAF file
                $mafFile = $info[ 0 ];
                $mafFile =~ s/\.vcf/\.maf/g;
                $mafFiles = $mafFiles . " " . $mafFile;
                
                ##### Extract file name
                @mafInfo = split('/', $vcfFile);
                $mafInfo = join('/', @mafInfo[0 .. $#mafInfo-1]);
                $sampleName = $mafInfo[$#mafInfo];

                ##### Create copy of the VCF file with .vep extenstion to skip VEP annotation step
                $vepFile = $info[ 0 ];
                $vepFile =~ s/\.vcf/\.vep\.vcf/g;
                
                system("ln -s $vcfFile $vepFile");
                
                ##### Run vcf2maf.pl script (https://github.com/mskcc/vcf2maf)
                system("perl $v2m  --input-vcf $vcfFile --output-maf $mafFile --ref-fasta $ref --filter-vcf 0 --species homo_sapiens --tumor-id $sampleName --normal-id $sampleName.normal");            
                system("rm $vepFile");
                
                ##### Compress VCFs
                system( "gzip $vcfFile" );
                
                #####  If only exonic regions are to be included than keep only variants with non-empty values in the "Exon_Number" column
                if ( $exons eq "TRUE" or $exons eq "T"  ) {
                    
                    ##### Open the new MAF file
                    open (MAF_ALL, '<', $mafFile) or die $!;
                    
                    $mafFile =~ s/\.maf/\.exonic.maf/g;
                    
                    ##### Open new MAF file to keep the exonic regions info
                    open( MAF_EXONIC, '>', $mafFile) or die "Could not open file '$mafFile' $!";
                    
                    ##### Get the header
                    $. = 0;
                    do { $mafHeader = <MAF_ALL> } until $. == 2 || eof;
                    chomp $mafHeader;
                    print( MAF_EXONIC '#version 2.4' . "\n" );
                    print( MAF_EXONIC $mafHeader . "\n" );
                    
                    ##### Get column number with "Variant_Classification" info
                    my @mafHeader = split('\t', $mafHeader);
                    #$exon_col = firstidx { $_ =~ m/.*?amino_acids.*?/i or $_ =~ m/.*?aa_mutation.*?/i or $_ =~ m/.*?aa_change.*?/i } @mafHeader;
                    $exon_col = firstidx { $_ eq "Variant_Classification" } @mafHeader;
                    
                    ##### Loop thorough all variants and keep only variants within exonic regions
                    while (my $var_record = <MAF_ALL>) {
                        
                        chomp $var_record;
                        
                        ##### Extract info about each variant
                        @varInfo = split('\t', $var_record);
                        
                       ##### Keep only variants with non-empty values within exonic regions
                        if ( $varInfo[ $exon_col ] eq "Missense_Mutation" or $varInfo[ $exon_col ] eq "Nonsense_Mutation" or $varInfo[ $exon_col ] eq "Frame_Shift_Del" or $varInfo[ $exon_col ] eq "Frame_Shift_Ins" or $varInfo[ $exon_col ] eq "In_Frame_Del" or $varInfo[ $exon_col ] eq "In_Frame_Ins" or $varInfo[ $exon_col ] eq "Silent" or $varInfo[ $exon_col ] eq "Translation_Start_Site" ) {

                            print( MAF_EXONIC $var_record . "\n" );
                        }
                    }
                
                    close (MAF_ALL);
                    close (MAF_EXONIC);
                }       
                
             } else {
                
                ##### Report VCFs listed in the provided input file which don't exist
                print( "File $vcfFile was not found and is ignored!\n\n");
            }
        }
    }
    
    ##### Concatenate MAF files from individual VCFs and remove multiple headers
    if ( $exons eq "TRUE" or $exons eq "T" ) {
        
        $mafFiles =~ s/\.maf/\.exonic.maf/g;
    }
    
    system("cat $mafFiles > $outMaf.tmp");
    system("grep -E -v 'version 2.4|Hugo_Symbol' $outMaf.tmp > $outMaf.tmp2; mv $outMaf.tmp2 $outMaf.tmp");
        
    ##### Add the header at the beginning of the final MAF file
    open ( MAF, '<',  $mafFile) or die "Could not open file '$mafFile' $!";
    $. = 0;
    do { $mafHeader = <MAF> } until $. == 2 || eof;
    chomp $mafHeader;
    system("echo '#version 2.4' > $outMaf.head");
    system("echo '$mafHeader' >> $outMaf.head");
    system("cat $outMaf.head $outMaf.tmp > $outMaf");
    
    ##### Remove temporary files
    system("rm $outMaf.head");
    system("rm $outMaf.tmp");
     
    print( "\n\nThe merged MAF file is saved in the following directory\n\n$outMaf\n\n");
    system( "date" );
    print( "\n" );
            
    close (FILES_LIST);
    close (MAF);
        
} else {
    usage ();
}

#===============================================================================
#    End of main
#===============================================================================

exit;

#===============================================================================
#    Subroutines
#===============================================================================

sub usage () {
    print <<"EOS";
    
usage: perl $0 -l /examples/example_vcf_list.txt  -s /tools/vcf2maf.pl  -e FALSE  -r /reference/GRCh37-lite.fa  -m /data/example.maf
       perl $0 -h
    
    Input data
    -l / --vcf_list:    Full path with name of a file listing VCF files, along with 
			corresponding directories, to be converted
    -e / --exons:       Include exonic regions only? TRUE/T or FALSE/F (defualt)
    -s / --v2m:         Full path to vcf2maf.pl script (https://github.com/mskcc/vcf2maf)
    -r / --ref:         Reference FASTA file

    Output data
    -m / --maf_file:    Full name MAF file to be created. It will be save in
                        the folder with the file listing VCF files
    
    Help
    -h / --help:        Print a brief help message and quit
    
EOS
exit;
}

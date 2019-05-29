#!/usr/bin/perl
################################################################################
#
#   File name: var_class_maf.pl
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
#	Description: Script for extracting variants with consequences of interest noted in the "Variant_Classification" filed in the user-defined MAF file (the default are exonic regions marked as "Missense_Mutation", "Nonsense_Mutation", "Frame_Shift_Del", "Frame_Shift_Ins", "In_Frame_Del", "In_Frame_Ins", "Silent" or "Translation_Start_Site" are seleced). The output file will be saved as MAF file with ".var_class.maf" extension.
#
#	Command line use example: perl var_class_maf.pl  -m /examples/example.maf
#
#	-m / --maf:         Full path with name of a MAF file to be converted
#	-v / --var_class:    List of variants classifications to incude in the subet MAF. The default list includes exonic regions, i.e. marked as "Missense_Mutation,Nonsense_Mutation,Frame_Shift_Del,Frame_Shift_Ins,In_Frame_Del,In_Frame_Ins,Silent,Translation_Start_Site" in the "Variant_Classification" field
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
my $maf;
my $var_class;
my $roiMaf;
my $mafHeader;
my $mafHeader_no;
my $var_class_col;
my @varInfo;

while ($arg = shift) {
    if ($arg =~ /^-m$/ || $arg =~ /^--maf/) {
        $maf = shift;
    } elsif ($arg =~ /^-v$/ || $arg =~ /^--var_class/) {
        $var_class = shift;
    } elsif ($arg =~ /-h/ || $arg =~ /--help/) {
        usage ();
    }
}

##### Check the required paramters
if ( $maf ) {
    
    ##### Extract the directory info for the final MAF file
    $roiMaf = $maf;
    $roiMaf =~ s/\.maf/\.var_class.maf/g;
    
    ##### Open MAF file
    open (MAF, '<', $maf) or die "Could not open file '$maf' $!";
    
    ##### Search for line with MAF header (the one containing "Variant_Classification" column)
    my $count = 0;
    
    while ( my $line = <MAF> ){
        
        $count ++;
        
        if ( $line =~ /Variant_Classification/ ){
            
           $mafHeader = $line;
           $mafHeader_no = $count;
        }
    }
    
    $mafHeader =~ s/"//g;
    close (MAF);
    
    ##### Open MAF file
    open (MAF, '<', $maf) or die "Could not open file '$maf' $!";
    
    ##### Skip lines before the header (containing "Variant_Classification" column)
    for ( my $i=0; $i < $mafHeader_no; $i++ ) {
        
        my $record = <MAF>;
    }
    
    ##### Open new MAF file to keep the variants classification info
    open( MAF_ROI, '>', $roiMaf) or die "Could not open file '$roiMaf' $!";
                    
    ##### Get the header
    #$. = 0;
    #do { $mafHeader = <MAF> } until $. == -1 || eof;
    #chomp $mafHeader;
    print( MAF_ROI '#version 2.4' . "\n" );
    print( MAF_ROI $mafHeader );
    
    ##### Get column number with "Variant_Classification" info
    my @mafHeader = split('\t', $mafHeader);
    #$var_class_col = firstidx { $_ =~ m/.*?amino_acids.*?/i or $_ =~ m/.*?aa_mutation.*?/i or $_ =~ m/.*?aa_change.*?/i } @mafHeader;
    $var_class_col = firstidx { $_ eq "Variant_Classification" } @mafHeader;
    
    ##### Put the variant classifications of interested into an array
    my @mafVar_class = split(',', $var_class);

    ##### Loop thorough all variants and keep only variants with classification of interest
    while (my $record = <MAF>) {
        
        chomp $record;
        $record =~ s/"//g;
            
        ##### Extract info about each variant
        @varInfo = split('\t', $record);
                        
        my @matched_vars = grep(/$varInfo[ $var_class_col ]/i, @mafVar_class);
        
        ##### Keep only variants with non-empty values after matching "Variant_Classification" field with variant classifications of interest
        if ( exists($matched_vars[0]) ) {
            
            print( MAF_ROI $record . "\n" );
        } 
    }
    close (MAF);
    close (MAF_ROI);
    
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
    
usage: perl $0 -m /examples/example.maf
       perl $0 -h
    
    Input data
    -m / --maf:        Full path with name of a MAF file to be converted
    
    Options
    -v / --var_class:  List of variants classifications to incude in the subet MAF. The default list includes exonic regions, i.e. marked as "Missense_Mutation,Nonsense_Mutation,Frame_Shift_Del,Frame_Shift_Ins,In_Frame_Del,In_Frame_Ins,Silent,Translation_Start_Site" in the "Variant_Classification" field
   
    Help
    -h / --help:        Print a brief help message and quit
    
EOS
exit;
}

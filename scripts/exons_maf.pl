#!/usr/bin/perl
################################################################################
#
#   File name: exons_maf.pl
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
#	Description: Script for extracting variants within exonic regions (e.i. marked as "Missense_Mutation", "Nonsense_Mutation", "Frame_Shift_Del", "Frame_Shift_Ins", "In_Frame_Del", "In_Frame_Ins", "Silent" or "Translation_Start_Site") from user-defined MAF file. The output file will be saved as MAF file with ".exonic.maf" extension.
#
#	Command line use example: perl exons_maf.pl  -m /examples/example.maf
#
#	-m / --maf:    Full path with name of a MAF file to be converted
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
my $exonicMaf;
my $mafHeader;
my $mafHeader_no;
my $exon_col;
my @varInfo;

while ($arg = shift) {
    if ($arg =~ /^-m$/ || $arg =~ /^--maf/) {
        $maf = shift;
    } elsif ($arg =~ /-h/ || $arg =~ /--help/) {
        usage ();
    }
}

##### Check the required paramters
if ( $maf ) {
    
    ##### Extract the directory info for the final MAF file
    $exonicMaf = $maf;
    $exonicMaf =~ s/\.maf/\.exonic.maf/g;
    
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
    
    ##### Open new MAF file to keep the exonic regions info
    open( MAF_EXONIC, '>', $exonicMaf) or die "Could not open file '$exonicMaf' $!";
                    
    ##### Get the header
    #$. = 0;
    #do { $mafHeader = <MAF> } until $. == -1 || eof;
    #chomp $mafHeader;
    print( MAF_EXONIC '#version 2.4' . "\n" );
    print( MAF_EXONIC $mafHeader );
    
    ##### Get column number with "Variant_Classification" info
    my @mafHeader = split('\t', $mafHeader);
    #$exon_col = firstidx { $_ =~ m/.*?amino_acids.*?/i or $_ =~ m/.*?aa_mutation.*?/i or $_ =~ m/.*?aa_change.*?/i } @mafHeader;
    $exon_col = firstidx { $_ eq "Variant_Classification" } @mafHeader;
    
    ##### Loop thorough all variants and keep only variants within exonic regions
    while (my $record = <MAF>) {
        
        chomp $record;
        $record =~ s/"//g;
            
        ##### Extract info about each variant
        @varInfo = split('\t', $record);
                        
        ##### Keep only variants with non-empty values within exonic regions
        if ( $varInfo[ $exon_col ] eq "Missense_Mutation" or $varInfo[ $exon_col ] eq "Nonsense_Mutation" or $varInfo[ $exon_col ] eq "Frame_Shift_Del" or $varInfo[ $exon_col ] eq "Frame_Shift_Ins" or $varInfo[ $exon_col ] eq "In_Frame_Del" or $varInfo[ $exon_col ] eq "In_Frame_Ins" or $varInfo[ $exon_col ] eq "Silent" or $varInfo[ $exon_col ] eq "Translation_Start_Site" ) {

                print( MAF_EXONIC $record . "\n" );
        }   
    }
    close (MAF);
    close (MAF_EXONIC);
    
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
    -m / --maf:    Full path with name of a MAF file to be converted
    
    Help
    -h / --help:        Print a brief help message and quit
    
EOS
exit;
}

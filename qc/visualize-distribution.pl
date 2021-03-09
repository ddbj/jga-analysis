#!/usr/bin/perl
BEGIN{ push(@INC, $ENV{LOCAL_PERL_MODULES}); }
use strict;
use warnings;
use Getopt::Std;
use vars qw($opt_h $opt_i $opt_n $opt_o);
&getopts('hi:n:o:');

# Define default parameters

# Usage
my $usage = <<_EOH_;

## Options ###########################################
## Required:
# -i    input metrics file
# -n    target variable name (e.g., autosome_PAR.coverage_mean)
# -o    output histogram file (PDF format)

## Optional:

## Others:
# -h print help

_EOH_
    ;

die $usage if $opt_h;

# Get command line options
my $datFile = $opt_i or die $usage;
my $varName = $opt_n or die $usage;
my $pdfFile = $opt_o or die $usage;

# Visualize distribution as a histogram
print STDERR "Visualizing distribution as a histogram...\n";
print STDERR "\t" . "Input data file       = " . $datFile . "\n";
print STDERR "\t" . "X-axis                = " . $varName . "\n";
print STDERR "\t" . "Output histogram file = " . $pdfFile . "\n";
    
my $Rfile = $pdfFile . ".R";
open R, ">$Rfile" or die "Can't open the file [ $Rfile ].\n";
print R ""
    . 'library(ggplot2)' . "\n"
    . 'library(readr)' . "\n"
    . "\n"
    . 'd <- as.data.frame( read_tsv("' . $datFile . '") )' . "\n"
    . 'g <- ggplot(d, aes(x = ' . $varName . '))' . "\n"
    . 'g <- g + geom_histogram(position="identity", alpha=0.8, color="darkgreen")' . "\n"
    . 'g <- g + theme_classic()' . "\n"
    . 'g <- g + theme(text=element_text(size=20))' . "\n"
    . 'g <- g + ylab("Number of subjects")' . "\n"
    . 'ggsave(file="' . $pdfFile . '", plot=g, height=5, width=8)' . "\n"
    . "\n";
close R;

system "R CMD BATCH $Rfile";
system "rm .RData" if -e ".RData";

print STDERR "\t" . "Log file              = " . $Rfile . "out" . "\n";
print STDERR "...done.\n\n";

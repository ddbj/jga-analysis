#!/usr/bin/perl
BEGIN{ push(@INC, $ENV{LOCAL_PERL_MODULES}); }
use strict;
use warnings;
use Getopt::Std;
use vars qw($opt_h $opt_i $opt_x $opt_y $opt_o);
&getopts('hi:x:y:o:');

# Define default parameters

# Usage
my $usage = <<_EOH_;

## Options ###########################################
## Required:
# -i    input metrics file
# -x    target variable name for X-axis (e.g., chrX_nonPAR.coverage_mean)
# -y    target variable name for Y-axis (e.g., chrY_nonPAR.coverage_mean)
# -o    output plot2D file (PDF format)

## Optional:

## Others:
# -h print help

_EOH_
    ;

die $usage if $opt_h;

# Get command line options
my $datFile = $opt_i or die $usage;
my $varX    = $opt_x or die $usage;
my $varY    = $opt_y or die $usage;
my $pdfFile = $opt_o or die $usage;

# Visualize as a 2d-plot
print STDERR "Visualizing as a 2d-plot...\n";
print STDERR "\t" . "Input data file       = " . $datFile . "\n";
print STDERR "\t" . "X-axis                = " . $varX . "\n";
print STDERR "\t" . "Y-axis                = " . $varY . "\n";
print STDERR "\t" . "Output histogram file = " . $pdfFile . "\n";

my $Rfile = $pdfFile . ".R";
open R, ">$Rfile" or die "Can't open the file [ $Rfile ].\n";
print R ""
    . 'library(ggplot2)' . "\n"
    . 'library(readr)' . "\n"
    . "\n"
    . 'd <- as.data.frame( read_tsv("' . $datFile . '") )' . "\n"
    . 'g <- ggplot(d, aes(x = ' . $varX . ', y = ' . $varY . '))' . "\n"
    . 'g <- g + geom_point(size = 2, color="darkgreen")' . "\n"
    . 'g <- g + theme_classic()' . "\n"
    . 'g <- g + theme(text=element_text(size=20))' . "\n"
    . 'ggsave(file="' . $pdfFile . '", plot=g, height=8, width=8)' . "\n"
    . "\n";
close R;

system "R CMD BATCH $Rfile";
system "rm .RData" if -e ".RData";

print STDERR "\t" . "Log file              = " . $Rfile . "out" . "\n";
print STDERR "...done.\n\n";

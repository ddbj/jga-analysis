#!/usr/bin/perl
BEGIN{ push(@INC, $ENV{LOCAL_PERL_MODULES}); }
use strict;
use warnings;
use Getopt::Std;
use vars qw($opt_h $opt_i $opt_o);
&getopts('hi:o:');

# Define default parameters

# Usage
my $usage = <<_EOH_;

## Options ###########################################
## Required:
# -i    input directory containing reports from vcreport (please specify via absolute path)
# -o    output file (a list of report file paths)

## Optional:

## Others:
# -h print help

_EOH_
    ;

die $usage if $opt_h;

# Get command line options
my $dir     = $opt_i or die $usage;
my $outFile = $opt_o or die $usage;

# Search report files
my $sampleID2file = searchReportFiles( $dir );

# Save report file paths
saveFilePaths( $outFile, $sampleID2file );


sub searchReportFiles {
    my $dir = shift;
    my $id2file = {};
    print STDERR "Searching report files in the directory [$dir]...\n";
    
    opendir DIR, $dir or die "Can't open a directory [ $dir ]";
    foreach( readdir(DIR) ){
	next if /^\.{1,2}$/;	# '.'や'..'をスキップ
	my $sampleID = $_;
	my $subdir   = $dir . '/' . $sampleID;
	if( -d $subdir ) {
	    opendir SUBDIR, $dir.'/'.$sampleID or die "Can't open a directory [ $subdir]";
	    foreach( readdir(SUBDIR) ){
		next if /^\.{1,2}$/;	# '.'や'..'をスキップ
		if( $_ eq "report.md" ) {
		    print STDERR "\t" . "A report was found: Sample ID = $sampleID\n"; 
		    $id2file->{$sampleID} = $subdir . '/report.md';
		}
	    }
	    closedir SUBDIR;
	}
    }
    closedir DIR;
    print STDERR "\t" . "Reports for " . scalar(keys %$id2file) . " samples were found.\n";
    print STDERR "...done.\n\n";
    return $id2file;
}

sub saveFilePaths {
    my $file    = shift;
    my $id2path = shift;
    print STDERR "Writing reprot file paths to the file [ $file ].\n";
    open OUT, ">$file" or die "Can't open the file [ $file ] to write.";
    my $cnt = 0;
    foreach my $id (sort keys %$id2path) {
	my $path = $id2path->{$id};
	print OUT $id . "\t" . $path . "\n";
	++$cnt;
    }
    close OUT;
    print STDERR "\t" . $cnt . " file paths were saved.\n";
    print STDERR "...done.\n\n";
}

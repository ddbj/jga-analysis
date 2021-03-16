#!/usr/bin/perl
BEGIN{ push(@INC, $ENV{LOCAL_PERL_MODULES}); }
use strict;
use warnings;
use Getopt::Std;
use vars qw($opt_h $opt_i $opt_a $opt_b $opt_c $opt_d $opt_e $opt_f $opt_g $opt_j $opt_k $opt_l $opt_o $opt_v);
&getopts('hi:a:b:c:d:e:f:g:j:k:l:o:v');

# Define default parameters

# Usage
my $usage = <<_EOH_;

## Options ###########################################
## Required:
# -i    input metrics file
# -a    minimum mean coverage for autosome-PAR region
# -b    maximum mean coverage for autosome-PAR region
# -c    minimum mean coverage for chrX-nonPAR region for male
# -d    maximum mean coverage for chrX-nonPAR region for male
# -e    minimum mean coverage for chrY-nonPAR region for male
# -f    maximum mean coverage for chrY-nonPAR region for male
# -g    minimum mean coverage for chrX-nonPAR region for femlae
# -j    maximum mean coverage for chrX-nonPAR region for femlae
# -k    minimum mean coverage for chrY-nonPAR region for female
# -l    maximum mean coverage for chrY-nonPAR region for female
# -o    output file (a file that reports QC results)

## Optional:
# -v    verbose mode

## Others:
# -h print help

_EOH_
    ;

die $usage if $opt_h;

# Get command line options
my $inFile  = $opt_i or die $usage;
my $autosomePAR_coverageMean_min          = $opt_a; die $usage if !defined $opt_a;
my $autosomePAR_coverageMean_max          = $opt_b; die $usage if !defined $opt_b;
my $chrXnonPAR_coverageMean_min_forMale   = $opt_c; die $usage if !defined $opt_c;
my $chrXnonPAR_coverageMean_max_forMale   = $opt_d; die $usage if !defined $opt_d;
my $chrYnonPAR_coverageMean_min_forMale   = $opt_e; die $usage if !defined $opt_e;
my $chrYnonPAR_coverageMean_max_forMale   = $opt_f; die $usage if !defined $opt_f;
my $chrXnonPAR_coverageMean_min_forFemale = $opt_g; die $usage if !defined $opt_g;
my $chrXnonPAR_coverageMean_max_forFemale = $opt_j; die $usage if !defined $opt_j;
my $chrYnonPAR_coverageMean_min_forFemale = $opt_k; die $usage if !defined $opt_k;
my $chrYnonPAR_coverageMean_max_forFemale = $opt_l; die $usage if !defined $opt_l;
my $dir     = $opt_i or die $usage;
my $outFile = $opt_o or die $usage;
my $verbose = 0; $verbose = 1 if defined $opt_v;

# Load QC metrics
my $sampleID2metrics = loadMetrics( $inFile );

# Perform QC
my $sampleID2qc = performQC( $sampleID2metrics );

# Save QC results
saveQcResults( $outFile, $sampleID2qc );

sub loadMetrics {
    my $file = shift;
    my $id2metrics = {};
    print STDERR "Loading metrics from the file [ $file ]...\n";
    open IN, $file or die "Can't open the file [ $file ] to read.";
    my $header = <IN>; chomp $header;
    my @hcols = split("\t", $header);
    while(<IN>) {
	chomp;
	my @cols = split("\t", $_);
	if( scalar(@cols) == scalar(@hcols) ) {
	    my $id = $cols[0];
	    my $metrics = {};
	    for( my $i=0 ; $i<scalar(@cols) ; ++$i ) {
		$metrics->{$hcols[$i]} = $cols[$i];
		$id = $cols[$i] if $hcols[$i] eq "ID";
	    }
	    $id2metrics->{$id} = $metrics;
	}
    }
    close IN;

    print STDERR "\t" . "Metrics for " . scalar(keys %$id2metrics) . " samples were loaded.\n";
    print STDERR "...done.\n\n";
    return $id2metrics;
}

sub performQC {
    my $id2metrics = shift;
    my $id2qc      = {};
    print STDERR "Performing QC...\n";
    my $passCovFilter = 0;
    my $failCovFilter = 0;
    my $male   = 0;
    my $female = 0;
    my $other = 0;
    foreach my $id (sort keys %$id2metrics) {
	my $metrics   = $id2metrics->{$id};
	my $covFilter = coverageFilter( $metrics );
	++$passCovFilter if $covFilter eq "PASS";
	++$failCovFilter if $covFilter eq "FAIL";

	my $sex = estimateSex( $metrics );
	++$male   if $sex eq "Male";
	++$female if $sex eq "Female";
	++$other  if $sex eq "Other";

	my $qc = {
	    COVERAGE_FILTER => $covFilter,
	    SEX_ESTIMATED   => $sex
	};
	$id2qc->{$id} = $qc;
	print STDERR "\t" . "ID=$id, COVERAGE_FILTER=$covFilter, SEX=$sex" . "\n" if $verbose;
    }

    print STDERR "\t" . "QC results for " . scalar(keys %$id2qc) . " samples were calculated.\n";
    print STDERR "\t" . "Coverage filter:\n"
	. "\t\t" . "PASS = " . $passCovFilter . "\n"
	. "\t\t" . "FAIL = " . $failCovFilter . "\n";
    print STDERR "\t" . "Estimated sex:\n"
	. "\t\t" . "Male   = " . $male . "\n"
	. "\t\t" . "Female = " . $female . "\n"
	. "\t\t" . "Other  = " . $other . "\n";
    print STDERR "...done.\n\n";
    return $id2qc;
}

sub coverageFilter {
    my $metrics = shift;
    return "FAIL" if $metrics->{"autosome_PAR.coverage_mean"} < $autosomePAR_coverageMean_min;
    return "FAIL" if $metrics->{"autosome_PAR.coverage_mean"} > $autosomePAR_coverageMean_max;
    return "PASS";
}

sub estimateSex {
    my $metrics = shift;
    return "Male" if isMale( $metrics );
    return "Female" if isFemale( $metrics );
    return "Other";
}

sub isMale {
    my $metrics = shift;
    return 0 if $metrics->{"chrX_nonPAR.coverage_mean_normalized"} < $chrXnonPAR_coverageMean_min_forMale;
    return 0 if $metrics->{"chrX_nonPAR.coverage_mean_normalized"} > $chrXnonPAR_coverageMean_max_forMale;
    return 0 if $metrics->{"chrY_nonPAR.coverage_mean_normalized"} < $chrYnonPAR_coverageMean_min_forMale;
    return 0 if $metrics->{"chrY_nonPAR.coverage_mean_normalized"} > $chrYnonPAR_coverageMean_max_forMale;
    return 1;
}

sub isFemale {
    my $metrics = shift;
    return 0 if $metrics->{"chrX_nonPAR.coverage_mean_normalized"} < $chrXnonPAR_coverageMean_min_forFemale;
    return 0 if $metrics->{"chrX_nonPAR.coverage_mean_normalized"} > $chrXnonPAR_coverageMean_max_forFemale;
    return 0 if $metrics->{"chrY_nonPAR.coverage_mean_normalized"} < $chrYnonPAR_coverageMean_min_forFemale;
    return 0 if $metrics->{"chrY_nonPAR.coverage_mean_normalized"} > $chrYnonPAR_coverageMean_max_forFemale;
    return 1;
}

sub saveQcResults {
    my $file  = shift;
    my $id2qc = shift;
    print STDERR "Writing QC results to the file [ $file ].\n";
    open OUT, ">$file" or die "Can't open the file [ $file ] to write.";
    my $cnt = 0;
    my @header = ( "ID", "coverage_filter", "sex_estimated" );
    print OUT join("\t", @header) . "\n";
    foreach my $id (sort keys %$id2qc) {
	my $qc = $id2qc->{$id};
	print OUT $id . "\t"
	    . $qc->{COVERAGE_FILTER} . "\t"
	    . $qc->{SEX_ESTIMATED} . "\n";
	++$cnt;
    }
    close OUT;
    print STDERR "\tQC results for " . $cnt . " samples were saved.\n";
    print STDERR "...done.\n\n";
}

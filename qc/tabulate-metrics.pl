#!/usr/bin/perl
BEGIN{ push(@INC, $ENV{LOCAL_PERL_MODULES}); }
use strict;
use warnings;
use Getopt::Std;
use vars qw($opt_h $opt_i $opt_o $opt_v $opt_d);
&getopts('hi:o:vd');

# Define default parameters

# Usage
my $usage = <<_EOH_;

## Options ###########################################
## Required:
# -i    input file (a list of report file paths)
# -o    output file (a file that tabulates metrics)

## Optional:
# -v    verbose mode
# -d    debug mode

## Others:
# -h print help

_EOH_
    ;

die $usage if $opt_h;

# Get command line options
my $inFile  = $opt_i or die $usage;
my $outFile = $opt_o or die $usage;
my $verbose = 0; $verbose = 1 if defined $opt_v;
my $debug   = 0; $debug   = 1 if defined $opt_d;

# Search report files
my $sampleID2metrics = loadReportMetrics( $inFile );

# Save metrics
saveMetrics( $outFile, $sampleID2metrics );


sub loadReportMetrics {
    my $file = shift;
    my $id2metrics = {};
    my $id2file = loadReportFilePaths( $inFile );
    print STDERR "Loading metrics...\n";
    foreach my $id (sort keys %$id2file) {
	my $path = $id2file->{$id};
	print STDERR "\t" . "ID=" . $id . ", PATH=" . $path . "\n";
	$id2metrics->{$id} = loadMetrics( $id, $path );
    }
    print STDERR "\t" . "Metrics for " . scalar(keys %$id2metrics) . " samples were loaded.\n";
    print STDERR "...done.\n\n";
    return $id2metrics;
}

sub loadReportFilePaths {
    my $file = shift;
    my $id2file = {};
    print STDERR "Loading report file paths from the file [ $file ]...\n";
    open IN, $file or die "Can't open the file [ $file ] to read.";
    while(<IN>) {
	chomp;
	my @cols = split("\t", $_);
	if( scalar(@cols) == 2 ) {
	    my ($id, $file) = @cols;
	    $id2file->{$id} = $file;
	}
    }
    close IN;
    print STDERR "\t" . "Report file paths for " . scalar(keys %$id2file) . " samples were loaded.\n";
    print STDERR "...done.\n\n";
    return $id2file;
}

sub loadMetrics {
    my $id   = shift;
    my $file = shift;
    open IN, $file or die "Can't open the file [ $file ] to read.";
    my $mode = "none";
    my $samtools_idxstats = "";
    my $picard_CollectWgsMetrics = "";
    while(<IN>) {
	chomp;
	if( /^### (.+)/ ) {
	    $mode = $1;
	    print STDERR "\t\t" . "mode = $mode\n" if $verbose;
	}
	if( $mode eq "samtools idxstats" ) {
	    $samtools_idxstats .= $_ . "\n";
	} elsif( $mode eq "picard CollectWgsMetrics" ) {
	    $picard_CollectWgsMetrics .= $_ . "\n";
	}
    }
    close IN;

    my $metrics = parsePicardCollectWgsMetrics( $id, $picard_CollectWgsMetrics );
    return $metrics
}

sub parseSamtoolsIdxstats {
    my $id                = shift;
    my $samtools_idxstats = shift;
    print STDERR $samtools_idxstats . "\n" if $debug;
    my $metrics = {
	numAutosomes     => 0,
	numChrX          => 0,
	numChrY          => 0,
	numAutosomeReads => 0,
	numChrXReads     => 0,
	numChrYReads     => 0
    };
    
    foreach ( split("\n", $samtools_idxstats) ) {
	my @cols = split(" ", $_);
	if( scalar(@cols) == 7 ) {
	    if( $cols[1] =~ /chr(\d+)/ ) {
		$cols[3] =~ s/,//g;
		$metrics->{numAutosomes}     += 1;
		$metrics->{numAutosomeReads} += $cols[3];
		print STDERR "Autosome: " . $cols[1] . "\t" . $cols[3] . "\n" if $debug;
	    } elsif( $cols[1] =~ /chrX/ ) {
		$cols[3] =~ s/,//g;
		$metrics->{numChrX}      += 1;
		$metrics->{numChrXReads} += $cols[3];
		print STDERR "Chr X: " . $cols[1] . "\t" . $cols[3] . "\n" if $debug;
	    } elsif( $cols[1] =~ /chrY/ ) {
		$cols[3] =~ s/,//g;
		$metrics->{numChrY}      += 1;
		$metrics->{numChrYReads} += $cols[3];
		print STDERR "Chr Y: " . $cols[1] . "\t" . $cols[3] . "\n" if $debug;
	    }
	}
    }

    print STDERR "\t" . "Warning: number of autosomes = " . $metrics->{numAutosomes} . "(ID = $id)" . "\n"
	if $metrics->{numAutosomes} != 22;
    print STDERR "\t" . "Warning: number of chrX      = " . $metrics->{numChrX} . "(ID = $id)" . "\n"
	if $metrics->{numChrX} != 1;
    print STDERR "\t" . "Warning: number of chrY      = " . $metrics->{numChrY} . "(ID = $id)" . "\n"
	if $metrics->{numChrY} != 1;

    print STDERR ""
	. "\t" . "Number of autosome reads = " . $metrics->{numAutosomeReads} . "\n"
	. "\t" . "Number of chrX reads     = " . $metrics->{numChrXReads} . "\n"
	. "\t" . "Number of chrY reads     = " . $metrics->{numChrYReads} . "\n";
    
    return $metrics;
}

sub parsePicardCollectWgsMetrics {
    my $id                = shift;
    my $picard_CollectWgsMetrics = shift;
    #print STDERR $picard_CollectWgsMetrics . "\n" if $debug;

    my $mode = "none";
    my $autosome_PAR = "";
    my $chrX_nonPAR  = "";
    my $chrY_nonPAR  = "";
    foreach ( split("\n", $picard_CollectWgsMetrics) ) {
	if( /^#### (.+)/ ) {
	    $mode = $1;
	    print STDERR "\t\t" . "mode = $mode\n" if $verbose;
	}
	if( $mode eq "autosome-PAR" ) {
	    $autosome_PAR .= $_ . "\n";
	} elsif( $mode eq "chrX-nonPAR" ) {
	    $chrX_nonPAR .= $_ . "\n";
	} elsif( $mode eq "chrY-nonPAR" ) {
	    $chrY_nonPAR .= $_ . "\n";
	}
    }

    my $metrics = {
	autosome_PAR => parsePicardCollectWgsMetricsEach( $id, "autosome-PAR", $autosome_PAR ),
	chrX_nonPAR  => parsePicardCollectWgsMetricsEach( $id, "chrX-nonPAR", $chrX_nonPAR ),
	chrY_nonPAR  => parsePicardCollectWgsMetricsEach( $id, "chrY-nonPAR", $chrY_nonPAR )
    };
    return $metrics;
}

sub parsePicardCollectWgsMetricsEach {
    my $id                           = shift;
    my $region                       = shift;
    my $picard_CollectWgsMetricsEach = shift;

    print STDERR $picard_CollectWgsMetricsEach . "\n" if $debug;
    my $metrics = {};
    my @lines = split("\n", $picard_CollectWgsMetricsEach);
    for( my $i=0 ; $i<scalar(@lines) ; ++$i ) {
	my @cols = split(" ", $lines[$i]);
	if( scalar(@cols) == 5 ) {
	    if( $cols[1] eq "statistic" and $cols[3] eq "coverage") {
		while( -1 ) {
		    my @_cols = split(" ", $lines[++$i]);
		    last if scalar(@_cols) == 0;
		    if( scalar(@_cols) == 5 ) {
			$metrics->{$_cols[1]} = $_cols[3] if $_cols[1] eq "mean";
			$metrics->{$_cols[1]} = $_cols[3] if $_cols[1] eq "SD";
			$metrics->{$_cols[1]} = $_cols[3] if $_cols[1] eq "median";
			$metrics->{$_cols[1]} = $_cols[3] if $_cols[1] eq "MAD";
		    }
		}
	    }
	}
    }

    print STDERR "\t" . "Warning: coverage mean is unknown (ID=$id, region=$region)\n" if !defined $metrics->{mean};
    print STDERR "\t" . "Warning: coverage median is unknown (ID=$id, region=$region)\n" if !defined $metrics->{median};
    print STDERR "\t" . "Warning: coverage SD is unknown (ID=$id, region=$region)\n" if !defined $metrics->{SD};
    print STDERR "\t" . "Warning: coverage MAD is unknown (ID=$id, region=$region)\n" if !defined $metrics->{MAD};
	

    print STDERR "\t\tCoverage metrics (ID=$id, region=$region):\n"
	. "\t\t\t" . "mean   = " . $metrics->{mean} . "\n"
	. "\t\t\t" . "median = " . $metrics->{median} . "\n"
	. "\t\t\t" . "SD     = " . $metrics->{SD} . "\n"
	. "\t\t\t" . "MAD    = " . $metrics->{MAD} . "\n" if $verbose;
    
    return $metrics;
}


sub saveMetrics {
    my $file       = shift;
    my $id2metrics = shift;
    print STDERR "Writing metrics to the file [ $file ].\n";
    open OUT, ">$file" or die "Can't open the file [ $file ] to write.";
    my $cnt = 0;
    my @header = ( "ID",
		   "autosome_PAR.coverage_mean",
		   "autosome_PAR.coverage_median",
		   "autosome_PAR.coverage_SD",
		   "autosome_PAR.coverage_MAD",
		   "chrX_nonPAR.coverage_mean_normalized", 
		   "chrX_nonPAR.coverage_mean",
		   "chrX_nonPAR.coverage_median",
		   "chrX_nonPAR.coverage_SD",
		   "chrX_nonPAR.coverage_MAD",
		   "chrY_nonPAR.coverage_mean_normalized", 
		   "chrY_nonPAR.coverage_mean",
		   "chrY_nonPAR.coverage_median",
		   "chrY_nonPAR.coverage_SD",
		   "chrY_nonPAR.coverage_MAD"
	);
    print OUT join("\t", @header) . "\n";

    foreach my $id (sort keys %$id2metrics) {
	my $metrics = $id2metrics->{$id};
	print OUT $id . "\t"
	    . $metrics->{autosome_PAR}->{mean} . "\t"
	    . $metrics->{autosome_PAR}->{median} . "\t"
	    . $metrics->{autosome_PAR}->{SD} . "\t"
	    . $metrics->{autosome_PAR}->{MAD} . "\t"
	    . ($metrics->{chrX_nonPAR}->{mean} / $metrics->{autosome_PAR}->{mean}) . "\t"
	    . $metrics->{chrX_nonPAR}->{mean} . "\t"
	    . $metrics->{chrX_nonPAR}->{median} . "\t"
	    . $metrics->{chrX_nonPAR}->{SD} . "\t"
	    . $metrics->{chrX_nonPAR}->{MAD} . "\t"
	    . ($metrics->{chrY_nonPAR}->{mean} / $metrics->{autosome_PAR}->{mean}) . "\t"
	    . $metrics->{chrY_nonPAR}->{mean} . "\t"
	    . $metrics->{chrY_nonPAR}->{median} . "\t"
	    . $metrics->{chrY_nonPAR}->{SD} . "\t"
	    . $metrics->{chrY_nonPAR}->{MAD} . "\n";
	++$cnt;
    }
    close OUT;
    print STDERR "\t" . "Metrics for" . $cnt . " samples were saved.\n";
    print STDERR "...done.\n\n";
}

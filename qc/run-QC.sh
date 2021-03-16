#!/bin/sh

# Usage
usage(){
    echo "Usage: "
    echo "CMD <config-file>"
    echo "ex) CMD template.run-QC.config.sh"
}

if [ $# -ne 1 ] ; then
    usage
    exit
fi

# Set input parameters
config=$1

# Load configuration
source $config

# Print environmental variables
echo ""
echo "*******************************************************"
echo "CONFIGURATION for run-QC"
echo "system directories:"
echo "  SRC_DIR    = ${SRC_DIR}"
echo "  SCRIPT_DIR = ${SCRIPT_DIR}"
echo ""
echo "inputs:"
echo "  VCREPORT_DIR = ${VCREPORT_DIR}"
echo ""
echo "outputs:"
echo "  OUT_DIR      = ${OUT_DIR}"
echo ""
echo "parameters for coverage filter:"
echo "  min        = ${autosomePAR_coverageMean_min}"
echo "  max        = ${autosomePAR_coverageMean_max}"
echo ""
echo "parameters for estimating male:"
echo "  chrX range = ${chrXnonPAR_coverageMean_min_forMale} - ${chrXnonPAR_coverageMean_max_forMale}"
echo "  chrY range = ${chrYnonPAR_coverageMean_min_forMale} - ${chrYnonPAR_coverageMean_max_forMale}"
echo ""
echo "parameters for estimating female:"
echo "  chrX range = ${chrXnonPAR_coverageMean_min_forFemale} - ${chrXnonPAR_coverageMean_max_forFemale}"
echo "  chrY range = ${chrYnonPAR_coverageMean_min_forFemale} - ${chrYnonPAR_coverageMean_max_forFemale}"
echo ""
echo "*******************************************************"
echo ""

cd ${OUT_DIR}

# Step 01: List up report files
list=${OUT_DIR}/report-list.txt
if [ ! -e $list ] ; then
    ${SRC_DIR}/listup-reports.pl \
	-i ${VCREPORT_DIR} \
	-o $list
fi

# Step 02: Tabulate metrics
metrics=${OUT_DIR}/metrics.txt
if [ ! -e $metrics ] ; then
    ${SRC_DIR}/tabulate-metrics.pl \
	-i $list \
	-o $metrics
fi

# Step 03: Visualize coverage distribution
autosomePAR_coverageMean_histogram=${OUT_DIR}/autosome-PAR.coverage_mean.histogram.pdf
if [ ! -e $autosomePAR_coverageMean_histogram ] ; then
    ${SRC_DIR}/visualize-distribution.pl \
	-i $metrics \
	-n "autosome_PAR.coverage_mean" \
	-o $autosomePAR_coverageMean_histogram
fi

# Step 04: Visualize coverage plot2D
coverageMean_plot2D=${OUT_DIR}/coverage_mean.plot2D.pdf
if [ ! -e $coverageMean_plot2D ] ; then
    ${SRC_DIR}/visualize-plot2D.pl \
	-i $metrics \
	-x "chrX_nonPAR.coverage_mean_normalized" \
	-y "chrY_nonPAR.coverage_mean_normalized" \
	-o $coverageMean_plot2D
fi

# Check parameters for coverage filter
if [ "$autosomePAR_coverageMean_min" = "" ] || [ "$autosomePAR_coverageMean_max" = "" ] ; then
    echo ""
    echo "*******************************************************"
    echo "Please specify parameters for coverage filter"
    echo "  'autosomePAR_coverageMean_min'"
    echo "  'autosomePAR_coverageMean_max'"
    echo ""
    echo "Histogram of mean coverage (autosome-PAR region) may be useful to determine these parameters:"
    echo "$autosomePAR_coverageMean_histogram"
    echo "*******************************************************"
    echo ""
    exit
fi

# Check parameters for estimating male
if [ "$chrXnonPAR_coverageMean_min_forMale" = "" ] || [ "$chrXnonPAR_coverageMean_max_forMale" = "" ] || [ "$chrYnonPAR_coverageMean_min_forMale" = "" ] || [ "$chrYnonPAR_coverageMean_max_forMale" = "" ] ; then
    echo ""
    echo "*******************************************************"
    echo "Please specify parameters for estimating male"
    echo "  'chrXnonPAR_coverageMean_min_forMale'"
    echo "  'chrXnonPAR_coverageMean_max_forMale'"
    echo "  'chrYnonPAR_coverageMean_min_forMale'"
    echo "  'chrYnonPAR_coverageMean_max_forMale'"
    echo ""
    echo "2D-plot of mean coverage (X-axis:chrX-nonPAR region, Y-axis:chrY-nonPAR) may be useful to determine these parameters:"
    echo "$coverageMean_plot2D"
    echo "*******************************************************"
    echo ""
    exit
fi

# Check parameters for estimating female
if [ "$chrXnonPAR_coverageMean_min_forFemale" = "" ] || [ "$chrXnonPAR_coverageMean_max_forFemale" = "" ] || [ "$chrYnonPAR_coverageMean_min_forFemale" = "" ] || [ "$chrYnonPAR_coverageMean_max_forFemale" = "" ] ; then
    echo ""
    echo "*******************************************************"
    echo "Please specify parameters for estimating female"
    echo "  'chrXnonPAR_coverageMean_min_forFemale'"
    echo "  'chrXnonPAR_coverageMean_max_forFemale'"
    echo "  'chrYnonPAR_coverageMean_min_forFemale'"
    echo "  'chrYnonPAR_coverageMean_max_forFemale'"
    echo ""
    echo "2D-plot of mean coverage (X-axis:chrX-nonPAR region, Y-axis:chrY-nonPAR) may be useful to determine these parameters:"
    echo "$coverageMean_plot2D"
    echo "*******************************************************"
    echo ""
    exit
fi

# Step 05: QC
QC=${OUT_DIR}/QC-results.txt
if [ ! -e $QC ] ; then
    ${SRC_DIR}/perform-QC.pl -v \
	-i $metrics \
	-a $autosomePAR_coverageMean_min \
	-b $autosomePAR_coverageMean_max \
	-c $chrXnonPAR_coverageMean_min_forMale \
	-d $chrXnonPAR_coverageMean_max_forMale \
	-e $chrYnonPAR_coverageMean_min_forMale \
	-f $chrYnonPAR_coverageMean_max_forMale \
	-g $chrXnonPAR_coverageMean_min_forFemale \
	-j $chrXnonPAR_coverageMean_max_forFemale \
	-k $chrYnonPAR_coverageMean_min_forFemale \
	-l $chrYnonPAR_coverageMean_max_forFemale \
	-o $QC
fi


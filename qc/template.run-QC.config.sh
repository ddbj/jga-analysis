#!/bin/sh

# Please specify paths in your system
export SRC_DIR=~/Projects/nbdc-dev/QC-dev

# Please specify input/output data prefix
export VCREPORT_DIR=~/Projects/nbdc-dev/test01/reports
export OUT_DIR=~/Projects/nbdc-dev/test01/QC

# Please specify parameters for coverage filter
# (ex) export autosomePAR_coverageMean_min=20
# (ex) export autosomePAR_coverageMean_max=80
export autosomePAR_coverageMean_min=20
export autosomePAR_coverageMean_max=80

# Please specify parameters for estimating male
# (ex) export chrXnonPAR_coverageMean_min_forMale=0.4
# (ex) export chrXnonPAR_coverageMean_max_forMale=0.6
# (ex) export chrYnonPAR_coverageMean_min_forMale=0.3
# (ex) export chrYnonPAR_coverageMean_max_forMale=0.5
export chrXnonPAR_coverageMean_min_forMale=0.4
export chrXnonPAR_coverageMean_max_forMale=0.6
export chrYnonPAR_coverageMean_min_forMale=0.3
export chrYnonPAR_coverageMean_max_forMale=0.5

# Please specify parameters for estimating female
# (ex) export chrXnonPAR_coverageMean_min_forFemale=0.8
# (ex) export chrXnonPAR_coverageMean_max_forFemale=1.2
# (ex) export chrYnonPAR_coverageMean_min_forFemale=0.0
# (ex) export chrYnonPAR_coverageMean_max_forFemale=0.1
export chrXnonPAR_coverageMean_min_forFemale=0.8
export chrXnonPAR_coverageMean_max_forFemale=1.2
export chrYnonPAR_coverageMean_min_forFemale=0.0
export chrYnonPAR_coverageMean_max_forFemale=0.1


#!/bin/sh

ln -s $VCF_GZ .
tabix -p vcf $(basename $VCF_GZ)

# JGA analysis multi-samples workflow
This workflow takes multiple gVCF files as input, performs joint call and variant quality score recalibration (VQSR), and outputs variant call results per dataset (aggregate VCF). The summarized data (sites-only aggregate VCF) was then calculated.

This workflow consists of the following steps:
- Joint call: GATK GenomicsDBImport (version 4.2.0.0), GATK GenotypeGVCFs (version 4.2.0.0), GATK VariantFiltration (version 4.2.0.0)
- VQSR: GATK GatherVcfs (version 4.2.0.0), GATK VariantRecalibrator --mode INDEL (version 4.2.0.0), GATK VariantRecalibrator --mode SNP (version 4.2.0.0), GATK ApplyVQSR -model INDEL (version 4.2.0.0), GATK ApplyVQSR -model SNP (version 4.2.0.0), bgzip (version 1.9), bcftools index -t (version 1.9)
- Calculate aggregate VCF metrics: GATK CollectVariantCallingMetrics (version 4.2.0.0)
- Calculate sites-only aggregate VCF: GATK MakeSitesOnlyVcf (version 4.2.0.0), bgzip (version 1.9), bcftools index -t (version 1.9)




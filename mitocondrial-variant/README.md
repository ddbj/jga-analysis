# JGA analysis mitochondrial short variant discovery workflow

This workflow detects mitochondrial short variants from the WGS data.

The calculation is basically performed according to [the methods proposed in GATK Best Practices](https://gatk.broadinstitute.org/hc/en-us/articles/4403870837275-Mitochondrial-short-variant-discovery-SNVs-Indels-). The reference implementation of the workflow is [GATK mitochondria WDL pipeline 4.1.8.0](https://github.com/broadinstitute/gatk/blob/4.1.8.0/scripts/mitochondria_m2_wdl/MitochondriaPipeline.wdl).

The workflow is composed of the following steps.

* Extract only the reads mapped to the mitochondrial genome: GATK PrintReads 4.2.4.0
* Convert the mapped BAM to an unmapped BAM: Picard RevertSam 2.18.27
* Detect and filter Variants
  * Align the unmapped BAM to the mitochondrial reference: Picard SamToFastq 2.18.27, BWA-MEM 0.7.15-r1140, Picard MergeBamAlignment 2.18.27
  * Align the unmapped BAM to the shifted mitochondrial reference: Picard SamToFastq 2.18.27, BWA-MEM 0.7.15-r1140, Picard MergeBamAlignment 2.18.27
  * Collect metrics of the alignments: Picard CollectWgsMetrics 2.18.27
  * Call variants on the mitochondrial reference: GATK Mutect2 4.2.4.0
  * Call variants on the shifted mitochondrial reference: GATK Mutect2 4.2.4.0
  * Add OA (original alignment) tags: Picard LiftoverVcf 2.18.27
  * Merge the results of the variant calling on the original and the shifted reference: Picard MergeVcfs 2.18.27, GATK MergeMutectStats 4.2.4.0
  * Filter the detected variants: GATK FilterMutectCalls 4.2.4.0, GATK VariantFiltration 4.2.4.0, GATK LeftAlignAndTrimVariants 4.2.4.0, GATK SelectVariants 4.2.4.0, haplochecker (contained in Docker image `us.gcr.io/broad-dsde-methods/haplochecker:haplochecker-0124`), GATK NuMTFilterTool 4.2.4.0, GATK MTLowHeteroplasmyFilterTool 4.2.4.0
* Caclulate per-base coverages: Picard CollectHsMetrics 2.18.27
* Convert mutiallelic sites to biallelic sites: GATK LeftAlignAndTrimVariants 4.2.4.0

## Requirements

* [cwltool](https://github.com/common-workflow-language/cwltool) (tested with version 3.0.20210319143721 and 3.1.20221008225030)

## Usage

Run `mitocondrial-variant/mitocondrial-variant/Workflows/MitochondriaPipeline.cwl`.

```
$ cwltool --outdir output/ --singularity mitocondrial-variant/mitocondrial-variant/Workflows/MitochondriaPipeline.cwl job-file.yaml
```

## Compatibility test

### Inputs

### Settings in our workflow

### Settings in the Terra workflow

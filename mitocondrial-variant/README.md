# JGA analysis mitochondrial short variant discovery workflow

This workflow detects mitochondrial short variants from WGS data.

The calculation is basically performed according to [the methods proposed in GATK Best Practices](https://gatk.broadinstitute.org/hc/en-us/articles/4403870837275-Mitochondrial-short-variant-discovery-SNVs-Indels-) and [its reference implementation](https://github.com/broadinstitute/gatk/blob/4.1.8.0/scripts/mitochondria_m2_wdl/MitochondriaPipeline.wdl).

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

In Terra platform, [Mitochondria-SNPs-Indels-hg38](https://anvil.terra.bio/#workspaces/help-gatk/Somatic-SNVs-Indels-GATK4) workspace provides an example of a mitochondrial variant call workflow (`1-MitochondriaPipeline`) based on GATK Best Practices.

We compared it with our workflow using NA12878 sample.

### Inputs

WGS CRAM of NA12878 was retrieved from [here](https://console.cloud.google.com/storage/browser/broad-public-datasets/NA12878;tab=objects?authuser=0&prefix=&forceOnObjectsSortingFiltering=false).

The mitochondrial references and other resources were retrieved from [here](https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0/chrM;tab=objects?authuser=0&prefix=&forceOnObjectsSortingFiltering=false).

### Settings in our workflow

Our workflow was run using the following job file.

```YAML
---
wgs_aligned_cram:
  class: File
  format: http://edamontology.org/format_3462
  path: NA12878.cram
full_reference:
  class: File
  format: http://edamontology.org/format_1929
  path: Homo_sapiens_assembly38.fasta
mt_reference:
  class: File
  format: http://edamontology.org/format_1929
  path: Homo_sapiens_assembly38.chrM.fasta
blacklisted_sites:
  class: File
  format: http://edamontology.org/format_3003
  path: blacklist_sites.hg38.chrM.bed
mt_shifted_reference:
  class: File
  format: http://edamontology.org/format_1929
  path: Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.fasta
shift_back_chain:
  class: File
  format: http://edamontology.org/format_3982
  path: ShiftBack.chain
control_region_shifted_reference_interval_list:
  class: File
  path: control_region_shifted.chrM.interval_list
non_control_region_interval_list:
  class: File
  path: non_control_region.chrM.interval_list
outprefix: NA12878
```

### Settings in the Terra workflow

The following input parameters were configured.

* The workflow verison was set to [4.1.8.0](https://github.com/broadinstitute/gatk/tree/4.1.8.0/scripts/mitochondria_m2_wdl).
* `gatk_docker` = `broadinstitute/gatk:4.2.4.0`

### Results

The VCFs from two workflows are available from [here](https://zenodo.org/record/7827923).

The detected variants were identical between two workflows. It was confirmed by the following commands.

```
$ diff <(grep -vE '^#' NA12878.chrM.final.vcf) <(grep -vE '^#' submissions_953e4b1e-711c-43c3-bf89-58243ffd8217_MitochondriaPipeline_0aa3c95f-2d45-4ceb-986e-f6aac3b998d0_call-AlignAndCall_AlignAndCall_8823cbe2-5b42-44af-bbe8-d7a4ee0a324e_call-FilterLowHetSites_NA12878.final.vcf)
```

```
$ diff <(grep -vE '^#' NA12878.chrM.final.split.vcf) <(grep -vE '^#' submissions_953e4b1e-711c-43c3-bf89-58243ffd8217_MitochondriaPipeline_0aa3c95f-2d45-4ceb-986e-f6aac3b998d0_call-SplitMultiAllelicSites_NA12878.final.split.vcf)
```

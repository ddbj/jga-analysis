# JGA analysis somatic short variant discovery workflow

This workflow detects somatic short variants from the sequencing data of a tumor sample (optionally combined with the sequencing data of a matched normal sample).

The calculation is performed according to [the methods proposed in GATK Best Practices](https://gatk.broadinstitute.org/hc/en-us/articles/360035894731-Somatic-short-variant-discovery-SNVs-Indels-) and is composed of the following steps.

* GATK Mutect2 4.2.4.0
* GATK GetPileupSummaries 4.2.4.0
* GATK CalculateContamination 4.2.4.0
* GATK FilterMutectCalls 4.2.4.0
* GATK Funcotator 4.2.4.0

(NOTE: Although LearnReadOrientationModel step is described in GATK Best Practice workflow, our workflow does not include this step.)

## Requirements

* [cwltool](https://github.com/common-workflow-language/cwltool) (tested with version 3.0.20210319143721)

## Usage

If both a tumor sample and a matched normal sample are provided, run `somatic-short-variant/Workflows/somatic-variant-call-TN.cwl`.

```
$ cwltool --outdir output/ --singularity somatic-short-variant/Workflows/somatic-variant-call-TN.cwl job-file-TN.yaml
```

If only a tumor sample is provided, run `somatic-short-variant/Workflows/somatic-variant-call-T.cwl`.

```
$ cwltool --outdir output/ --singularity somatic-short-variant/Workflows/somatic-variant-call-T.cwl job-file-T.yaml
```

## Compatibility test

In Terra platform, [Somatic-SNVs-Indels-GATK4](https://anvil.terra.bio/#workspaces/help-gatk/Somatic-SNVs-Indels-GATK4) workspace provides an example of a somatic variant call workflow (`2-Mutect2-GATK4`) based on GATK Best Practices.

We compared it with our workflow using a tumor and a matched normal sample.

### Inputs

The input data for variant call were retrieved from [here](https://console.cloud.google.com/storage/browser/gatk-best-practices/somatic-hg38;tab=objects?pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22))&authuser=0&prefix=&forceOnObjectsSortingFiltering=false).

Funcotator data sources were retrieved from [here](https://console.cloud.google.com/storage/browser/broad-public-datasets/funcotator;tab=objects?authuser=0&prefix=&forceOnObjectsSortingFiltering=false).

We used HCC1143 (tumor and normal) aligned to hg38 as the target of variant identification.

### Settings in our workflow

Our workflow was run using the following job file.

```YAML
---
reference:
  class: File
  format: http://edamontology.org/format_1929
  path: Homo_sapiens_assembly38.fasta
tumor_cram:
  class: File
  format: http://edamontology.org/format_3462
  path: hcc1143_T_clean.cram
normal_cram:
  class: File
  format: http://edamontology.org/format_3462
  path: hcc1143_N_clean.cram
tumor_name: HCC1143_tumor
normal_name: HCC1143_normal
germline_resource:
  class: File
  format: http://edamontology.org/format_3016
  path: af-only-gnomad.hg38.vcf.gz
panel_of_normals:
  class: File
  format: http://edamontology.org/format_3016
  path: 1000g_pon.hg38.vcf.gz
variants_for_contamination:
  class: File
  format: http://edamontology.org/format_3016
  path: small_exac_common_3.hg38.vcf.gz
Mutect2_java_options: -Xmx64G
Funcotator_data_sources:
  class: Directory
  path: funcotator_dataSources.v1.6.20190124s
Funcotator_transcript_selection_list:
  class: File
  path: transcriptList.exact_uniprot_matches.AKT1_CRLF2_FGFR1.txt
outprefix: HCC1143
```

For the input to the workflow, the sample BAMs were converted to CRAMs. The contents of Funcotator data sources `funcotator_dataSources.v1.6.20190124s.tar.gz` were extracted to directory `funcotator_dataSources.v1.6.20190124s`.

### Settings in the Terra workflow

The following input parameters were configured.

* The workflow verison was set to [4.1.8.1](https://github.com/broadinstitute/gatk/tree/4.1.8.1/scripts/mutect2_wdl).
* `gatk_docker` = `broadinstitute/gatk:4.2.4.0`
* The reference was changed to hg38 (The original Terra workspace uses hg19 as the reference).
* `tumor_reads` = `hcc1143_T_clean.bam`
* `normal_reads` = `hcc1143_N_clean.bam`
* `funco_data_sources_tar_gz` = `funcotator_dataSources.v1.6.20190124s.tar.gz`
* `funco_reference_version` = `hg38`
* `funco_transcript_selection_list` = `transcriptList.exact_uniprot_matches.AKT1_CRLF2_FGFR1.txt`
* `gnomad` = `af-only-gnomad.hg38.vcf.gz`
* `m2_extra_args` = `--downsampling-stride 20 --max-reads-per-alignment-start 6 --max-suspicious-reads-per-alignment-start 6`
* `pon` = `1000g_pon.hg38.vcf.gz`
* `variants_for_contamination` = `small_exac_common_3.hg38.vcf.gz`

### Results

The VCFs and MAFs from two workflows are available from [here](https://zenodo.org/record/7821043#.ZDZ2GxXP2oc).

The detected variants and their annotations were identical between two workflows. It was confirmed by the following commands.

```
$ diff <(gunzip -c HCC1143.somatic.filter.vcf.gz | grep -vE "^#") <(grep -vE "^#" submissions_4e62b5bb-6f9c-431f-9327-378c68e6e4af
_Mutect2_e4638ec4-1ce5-4da8-852d-3d17893751e4_call-Filter_hcc1143_T_clean-filtered.vcf)
```

```
$ diff <(grep -vE '^#' HCC1143.somatic.filter.annotated.maf) <(grep -vE '^#' submissions_4e62b5bb-6f9c-431f-9327-378c68e6e4af_Mutect2_e4638ec4-1ce5-4da8-852d-3d17893751e4_call-Funcotate_hcc1143_T_clean-filtered.annotated.maf)
```

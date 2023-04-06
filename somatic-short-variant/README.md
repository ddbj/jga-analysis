# JGA analysis somatic short variant discovery workflow

This workflow detects somatic short variants from the sequencing data of a tumor sample (optionally combined with the sequencing data of a matched normal sample).

The calculation is performed according to the protocol proposed by [GATK Best Practice](https://gatk.broadinstitute.org/hc/en-us/articles/360035894731-Somatic-short-variant-discovery-SNVs-Indels-) and is composed of the following steps.

* Mutect2 4.2.4.0
* GetPileupSummaries 4.2.4.0
* CalculateContamination 4.2.4.0
* FilterMutectCalls 4.2.4.0
* Funcotator 4.2.4.0

(NOTE: Although LearnReadOrientationModel step is described run in GATK Best Practice workflow, our workflow does not include this step.)

## Requirements

* [cwltool](https://github.com/common-workflow-language/cwltool)

## Usage

If a tumor sample and a matched normal sample are provided, run `somatic-short-variant/Workflows/somatic-variant-call-TN.cwl`.

```
$ cwltool --outdir output/ --singularity somatic-short-variant/Workflows/somatic-variant-call-TN.cwl job-file-TN.yaml
```

If only a tumor sample is provided, run `somatic-short-variant/Workflows/somatic-variant-call-T.cwl`.

```
$ cwltool --outdir output/ --singularity somatic-short-variant/Workflows/somatic-variant-call-T.cwl job-file-T.yaml
```

## Compatibility test

We compared our workflow (tumor/normal pair) with [2-Mutect2-GATK4](https://anvil.terra.bio/#workspaces/help-gatk/Somatic-SNVs-Indels-GATK4/workflows/help-gatk/2-Mutect2-GATK4) workflow of Somatic-SNVs-Indels-GATK4 workspace in Terra platform.

### Inputs

The input data for variant call are retrieved from [here](https://console.cloud.google.com/storage/browser/gatk-best-practices/somatic-hg38;tab=objects?pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22))&authuser=0&prefix=&forceOnObjectsSortingFiltering=false).

Funcotator data sources are retrieved from [here](https://console.cloud.google.com/storage/browser/broad-public-datasets/funcotator;tab=objects?authuser=0&prefix=&forceOnObjectsSortingFiltering=false).

We used HCC1143 (tumor and normal) aligned to hg38 for the target of variant identification.

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

* The workflow verison = [4.1.8.1](https://github.com/broadinstitute/gatk/tree/4.1.8.1/scripts/mutect2_wdl)
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

The identified variants and their annotations were identical between two workflows.

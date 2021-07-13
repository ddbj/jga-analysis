#!/usr/bin/env cwl-runner

class: Workflow
id: fastqPE2bamworkflow
label: fastqPE2bamworkflow
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  ResourceRequirement:
    outdirMin: 40960
    ramMin: 40960
inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .alt
      - .fai
      - ^.dict
  # bams2cram
  use_bqsr:
    type: boolean
  dbsnp:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    doc: Homo_sapiens_assembly38.dbsnp138.vcf
  mills:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
  known_indels:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Homo_sapiens_assembly38.known_indels.vcf.gz
  # haplotypecaller interval=autosome-PAR, ploidy=2
  haplotypecaller_autosome_PAR_ploidy_2_interval_bed:
    type: File
  # haplotypecaller interval=chrX-nonPAR, ploidy=2
  haplotypecaller_chrX_nonPAR_ploidy_2_interval_bed:
    type: File
    format: edam:format_3584
  # haplotypecaller interval=chrX-nonPAR, ploidy=1
  haplotypecaller_chrX_nonPAR_ploidy_1_interval_bed:
    type: File
    format: edam:format_3584
  # haplotypecaller interval=chrY-nonPAR, ploidy=1
  haplotypecaller_chrY_nonPAR_ploidy_1_interval_bed:
    type: File
    format: edam:format_3584
  # scatter
  inputSamples:
    type:
      type: array
      items:
        - type: record
          fields:
            # scatter
            sample_id:
              type: string
            runlist_pe:
              type:
                type: array
                items:
                  - type: record
                    fields:
                      run_id:
                        type: string
                        doc: Read group identifier (ID) in RG line
                      platform_name:
                        type: string
                        doc: Platform/technology used to produce the read (PL) in RG line
                      fastq1:
                        type: File
                        format: edam:format_1930
                        doc: FastQ file from next-generation sequencers
                      fastq2:
                        type: File
                        doc: FastQ file from next-generation sequencers
steps:
  persampleworkflow:
    run: ./fastqPE2bam.cram.haplotypecaller.cwl
    in:
      reference: reference
      # bams2cram
      use_bqsr: use_bqsr
      dbsnp: dbsnp
      mills: mills
      known_indels: known_indels
      # haplotypecaller common
      haplotypecaller_autosome_PAR_ploidy_2_interval_bed: haplotypecaller_autosome_PAR_ploidy_2_interval_bed
      haplotypecaller_chrX_nonPAR_ploidy_2_interval_bed: haplotypecaller_chrX_nonPAR_ploidy_2_interval_bed
      haplotypecaller_chrX_nonPAR_ploidy_1_interval_bed: haplotypecaller_chrX_nonPAR_ploidy_1_interval_bed
      haplotypecaller_chrY_nonPAR_ploidy_1_interval_bed: haplotypecaller_chrY_nonPAR_ploidy_1_interval_bed
      #
      inputSamples: inputSamples
      sample_id:
        valueFrom: $(inputs.inputSamples.sample_id)
      runlist_pe:
        valueFrom: $(inputs.inputSamples.runlist_pe)
    scatter:
      - inputSamples
    scatterMethod: dotproduct
    out:
      - bam
      - haplotypecaller_chrY_nonPAR_ploidy_1_bcftools_stats_log
outputs:
#   bam:
#     type: File[]
#     outputSource: persampleworkflow/bam
  haplotypecaller_chrY_nonPAR_ploidy_1_bcftools_stats_log:
    type: File[]
    outputSource: persampleworkflow/haplotypecaller_chrY_nonPAR_ploidy_1_bcftools_stats_log

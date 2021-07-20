#!/usr/bin/env cwl-runner

class: Workflow
id: fastqPE2bamworkflow
label: fastqPE2bamworkflow
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

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
  RG_ID:
    type: string
    doc: Read group identifier (ID) in RG line
  RG_PL:
    type: string
    doc: Platform/technology used to produce the read (PL) in RG line
  RG_PU:
    type: string
    doc: Platform Unit (PU) in RG line
  RG_LB:
    type: string
    doc: DNA preparation library identifier (LB) in RG line
  RG_SM:
    type: string
    doc: Sample (SM) identifier in RG line
  fastq1:
    type: File
    format: edam:format_1930
    doc: FastQ file from next-generation sequencers
  fastq2:
    type: File
    format: edam:format_1930
    doc: FastQ file from next-generation sequencers
  outprefix:
    type: string
  bwa_num_threads:
    type: int
    doc: number of cpu cores to be used
    default: 1
  bwa_bases_per_batch:
    type: int
    doc: bases in each batch
    default: 10000000
  sortsam_java_options:
    type: string
    default: -XX:-UseContainerSupport -Xmx30g
  sortsam_max_records_in_ram:
    type: int
    default: 5000000
steps:
  fastqPE2bam:
    run: ../Tools/fastqPE2bam.cwl
    in:
      reference: reference
      RG_ID: RG_ID
      RG_LB: RG_LB
      RG_PL: RG_PL
      RG_PU: RG_PU
      RG_SM: RG_SM
      fastq1: fastq1
      fastq2: fastq2
      outprefix: outprefix
    out:
      - bam
      - log

outputs:
  bam:
    type: File
    outputSource: fastqPE2bam/bam
  log:
    type: File
    outputSource: fastqPE2bam/log

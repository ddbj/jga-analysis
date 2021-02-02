#!/usr/bin/env cwl-runner

class: CommandLineTool
id: fastqSE2bam
label: fastqSE2bam
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/tafujino/jga-analysis/fastq2cram:latest

baseCommand: [ bash, /tools/fastq2bam.sh ]

inputs:
  - id: reference
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
  - id: RG_ID
    type: string
    doc: Read group identifier (ID) in RG line
  - id: RG_PL
    type: string
    doc: Platform/technology used to produce the read (PL) in RG line
  - id: RG_PU
    type: string
    doc: Platform Unit (PU) in RG line
  - id: RG_LB
    type: string
    doc: DNA preparation library identifier (LB) in RG line
  - id: RG_SM
    type: string
    doc: Sample (SM) identifier in RG line
  - id: fastq
    type: File
    format: edam:format_1930
    doc: FastQ file from next-generation sequencers
  - id: outprefix
    type: string
  - id: bwa_num_threads
    type: int
    doc: number of cpu cores to be used
    default: 1
  - id: bwa_bases_per_batch
    type: int
    doc: bases in each batch
    default: 10000000
  - id: sortsam_java_options
    type: string
    default: -XX:-UseContainerSupport -Xmx30g
  - id: sortsam_max_records_in_ram
    type: int
    default: 5000000

outputs:
  - id: bam
    type: File
    outputBinding:
      glob: $(inputs.outprefix).bam
    format: edam:format_2572
  - id: log
    type: stderr

stderr: $(inputs.outprefix).bam.log

requirements:
  EnvVarRequirement:
    envDef:
      REFERENCE: $(inputs.reference.path)
      FASTQ1: $(inputs.fastq.path)
      FASTQ2: ''
      RG_ID: $(inputs.RG_ID)
      RG_PL: $(inputs.RG_PL)
      RG_PU: $(inputs.RG_PU)
      RG_LB: $(inputs.RG_LB)
      RG_SM: $(inputs.RG_SM)
      BAM: $(inputs.outprefix).bam
      BWA_BASES_PER_BATCH: $(inputs.bwa_bases_per_batch)
      BWA_NUM_THREADS: $(inputs.bwa_num_threads)
      SORTSAM_JAVA_OPTIONS: $(inputs.sortsam_java_options)
      SORTSAM_MAX_RECORDS_IN_RAM: $(inputs.sortsam_max_records_in_ram)

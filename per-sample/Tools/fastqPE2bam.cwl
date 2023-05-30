#!/usr/bin/env cwl-runner

class: CommandLineTool
id: fastqPE2bam
label: fastqPE2bam
cwlVersion: v1.2

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/manabuishii/jga-analysis/fastq2cram-bqsr-haplotypecaller:dev-manabuishii.1.1.4
  ResourceRequirement:
    ramMin: $(inputs.fastq2bam_ram_min)
    coresMin: $(inputs.bwa_num_threads)

baseCommand: [ bash, /tools/fastq2bam.sh ]

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
    inputBinding:
      position: 31
  RG_ID:
    type: string
    doc: Read group identifier (ID) in RG line
    inputBinding:
      position: 11
  RG_PL:
    type: string
    doc: Platform/technology used to produce the read (PL) in RG line
    inputBinding:
      position: 12
  RG_PU:
    type: string
    doc: Platform Unit (PU) in RG line
    inputBinding:
      position: 13
  RG_LB:
    type: string
    doc: DNA preparation library identifier (LB) in RG line
    inputBinding:
      position: 14
  RG_SM:
    type: string
    doc: Sample (SM) identifier in RG line
    inputBinding:
      position: 15
  fastq1:
    type: File
    format: edam:format_1930
    doc: FastQ file from next-generation sequencers
    inputBinding:
      position: 16
  fastq2:
    type: File
    format: edam:format_1930
    doc: FastQ file from next-generation sequencers
    inputBinding:
      position: 17
  outprefix:
    type: string
  # bam:
  #   type: string
    inputBinding:
      valueFrom: $(self).bam
      position: 32
  fastq2bam_ram_min:
    type: int
    doc: size of RAM (in MB) to be specified in 
    default: 48000
  bwa_num_threads:
    type: int
    doc: number of cpu cores to be used
    default: 1
    inputBinding:
      position: 18
  bwa_bases_per_batch:
    type: int
    doc: bases in each batch
    default: 10000000
    inputBinding:
      position: 19
  sortsam_java_options:
    type: string
    default: -XX:-UseContainerSupport -Xmx30g
    inputBinding:
      position: 20
  sortsam_max_records_in_ram:
    type: int
    default: 5000000
    inputBinding:
      position: 21

outputs:
  bam:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).bam
    format: edam:format_2572
  log:
    type: stderr

stderr: $(inputs.outprefix).bam.log

#!/usr/bin/env cwl-runner

class: Workflow
id: haplotypecaller
label: haplotypecaller
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict
  cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
  sample_name:
    type: string
  interval_name:
    type: string
  interval_bed:
    type: File
    format: edam:format_3584
  gatk4_HaplotypeCaller_java_options:
    type: string?
  gatk4_HaplotypeCaller_num_threads:
    type: int
    default: 1
  ploidy:
    type: int
  bgzip_num_threads:
    type: int
    default: 1

steps:
  gatk4-HaplotypeCaller:
    label: gatk4-HaplotypeCaller
    run: ../Tools/gatk4-HaplotypeCaller.cwl
    in:
      reference: reference
      cram: cram
      sample_name: sample_name
      interval_name: interval_name
      interval_bed: interval_bed
      java_options: gatk4_HaplotypeCaller_java_options
      num_threads: gatk4_HaplotypeCaller_num_threads
      ploidy: ploidy
    out:
      [vcf, log]
  bgzip:
    label: bgzip
    run: ../Tools/bgzip.cwl
    in:
      vcf: gatk4-HaplotypeCaller/vcf
      num_threads: bgzip_num_threads
    out:
      [vcf_gz, log]
  tabix:
    label: tabix
    run: ../Tools/tabix.cwl
    in:
      vcf_gz: bgzip/vcf_gz
    out:
      [tbi, log]

outputs:
  vcf_gz:
    type: File
    format: edam:format_3016
    outputSource: bgzip/vcf_gz
  tbi:
    type: File
    format: edam:format_3616
    outputSource: tabix/tbi
  haplotypecaller_log:
    type: File
    outputSource: gatk4-HaplotypeCaller/log
  bgzip_log:
    type: File
    outputSource: bgzip/log
  tabix_log:
    type: File
    outputSource: tabix/log

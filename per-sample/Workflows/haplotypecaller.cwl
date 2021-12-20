#!/usr/bin/env cwl-runner

class: Workflow
id: haplotypecaller
label: haplotypecaller
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/
requirements:
  ResourceRequirement:
    ramMin: $(inputs.haplotypecaller_ram_min)
    coresMin: $(inputs.gatk4_HaplotypeCaller_num_threads)

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
  interval_list:
    type: File
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
  haplotypecaller_ram_min:
    type: int
    doc: size of RAM (in MB) to be specified in 
    default: 48000

steps:
  picard-CollectWgsMetrics:
    label: picard-CollectWgsMetrics
    run: ../Tools/picard-CollectWgsMetrics_gatk4.cwl
    in:
      cram: cram
      reference: reference
      interval_name: interval_name
      interval_list: interval_list
    out: [wgs_metrics, log]
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
    out: [vcf, log]
  bgzip:
    label: bgzip
    run: ../Tools/bgzip.cwl
    in:
      vcf: gatk4-HaplotypeCaller/vcf
      num_threads: bgzip_num_threads
    out: [vcf_gz, log]
  tabix:
    label: tabix
    run: ../Tools/tabix-bgzipped-vcf.cwl
    in:
      vcf_gz: bgzip/vcf_gz
    out: [indexed_vcf_gz, log]
  bcftools-stats:
    label: bcftools-stats
    run: ../Tools/bcftools-stats.cwl
    in:
      vcf: tabix/indexed_vcf_gz
    out: [bcftools_stats, log]

outputs:
  vcf_gz:
    type: File
    format: edam:format_3016
    outputSource: tabix/indexed_vcf_gz
  wgs_metrics:
    type: File
    outputSource: picard-CollectWgsMetrics/wgs_metrics
  wgs_metrics_log:
    type: File
    outputSource: picard-CollectWgsMetrics/log
  haplotypecaller_log:
    type: File
    outputSource: gatk4-HaplotypeCaller/log
  bgzip_log:
    type: File
    outputSource: bgzip/log
  tabix_log:
    type: File
    outputSource: tabix/log
  bcftools_stats:
    type: File
    outputSource: bcftools-stats/bcftools_stats
  bcftools_stats_log:
    type: File
    outputSource: bcftools-stats/log

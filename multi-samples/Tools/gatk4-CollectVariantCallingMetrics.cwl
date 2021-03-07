#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-CollectVariantCallingMetrics
label: gatk4-CollectVariantCallingMetrics
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'

requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.2.0.0
  ShellCommandRequirement: {}
  
baseCommand: java

inputs:
  vcf:
    type: File
    format: edam:format_3016
    doc: A VCF file containing variants
    secondaryFiles:
      - .idx
    inputBinding:
      prefix: -INPUT
      position: 4

  dbsnp:
    type: File
    format: edam:format_3016
    doc: Reference dbSNP file in dbSNP or VCF format.
    secondaryFiles:
      - .idx
    inputBinding:
      prefix: --DBSNP
      position: 5

  sequence_dictionary:
    type: File
    doc: If present, speeds loading of dbSNP file, will look for dictionary in vcf if not present here.
    inputBinding:
      prefix: --SEQUENCE_DICTIONARY
      position: 6

  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: --THREAD_COUNT
      position: 7

  interval_list:
    type: File
    doc: Target intervals to restrict analysis to.
    inputBinding:
      prefix: --TARGET_INTERVALS
      position: 8

  outprefix:
    type: string

  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx3g -Xms3g
    inputBinding:
      position: 1
      shellQuote: false
    
outputs:
  - id: variant_calling_detail_metrics
    type: File
    outputBinding:
      glob: $(inputs.outprefix).variant_calling_detail_metrics
  - id: variant_calling_summary_metrics
    type: File
    outputBinding:
      glob: $(inputs.outprefix).variant_calling_summary_metrics
  - id: log
    type: stderr

stderr: $(inputs.outprefix).variant_calling_metrics.log
    
arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: CollectVariantCallingMetrics
  - position: 9
    prefix: -OUTPUT
    valueFrom: $(inputs.outprefix)

    

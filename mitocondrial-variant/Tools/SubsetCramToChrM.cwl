#!/usr/bin/env cwl-runner

class: CommandLineTool
id: SubsetCramToChrM
label: SubsetCramToChrM
doc: Subsets a whole genome CRAM to just Mitochondria reads
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.4.0

baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    inputBinding:
      position: 1
      prefix: --java-options
  full_reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      position: 3
      prefix: -R
  cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
    inputBinding:
      position: 7
      prefix: -I
  contig_name:
    type: string?
    default: chrM
    inputBinding:
      position: 4
      prefix: -L
  outprefix:
    type: string
  # Although there exists --read-index option in the original implementation in WDL,
  # we did not add it to our CWL implementation. The path to the CRAM index is
  # inferred automatically by PrintReads command.

outputs:
  subset_bam:
    type: File
    format: edam:format_2572
    outputBinding:
      glob: $(inputs.outprefix).bam
    secondaryFiles:
      - ^.bai
  log:
    type: stderr

stderr: $(inputs.outprefix).log

arguments:
  - position: 2
    valueFrom: PrintReads
  - position: 5
    prefix: --read-filter
    valueFrom: MateOnSameContigOrNoMappedMateReadFilter
  - position: 6
    prefix: --read-filter
    valueFrom: MateUnmappedAndUnmappedReadFilter
  - position: 8
    prefix: -O
    valueFrom: $(inputs.outprefix).bam

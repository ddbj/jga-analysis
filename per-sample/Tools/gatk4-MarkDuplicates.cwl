#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-MarkDuplicates
label: gatk4-MarkDuplicates
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/tafujino/jga-analysis/fastq2cram:latest

baseCommand: /usr/bin/java

inputs:
  java_options:
    type: string
    default: -XX:-UseContainerSupport -Xmx30g
    inputBinding:
      position: 1
  in_bams:
    type: File[]
    format: edam:format_2572
    inputBinding:
      position: 4
    doc: BAM files to be merged
  outprefix:
    type: string

outputs:
  markdup_bam:
    type: File
    format: edam:format_2572
    outputBinding:
      glob: $(inputs.outprefix).markdup.bam
  metrics:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).markdup.metrics.txt
  log:
    type: stderr

stderr: $(inputs.outprefix).markdup.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /tools/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar
  - position: 3
    valueFrom: MarkDuplicates
  - position: 5
    prefix: -O=
    separate: false
    valueFrom: $(inputs.outprefix).markdup.bam
  - position: 6
    prefix: -M=
    valueFrom: $(inputs.outprefix).markdup.metrics.txt

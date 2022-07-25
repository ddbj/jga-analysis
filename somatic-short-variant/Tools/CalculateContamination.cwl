#!/usr/bin/env cwl-runner

class: CommandLineTool
id: CalculateContamination
label: CalculateContamination
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.6.1

baseCommand: [ gatk ]

inputs:
  java_options:
    type: string?
    inputBinding:
      position: 1
      prefix: --java-options
  tumor_pileups:
    type: File
    inputBinding:
      position: 3
      prefix: -I
  normal_pileups:
    type: File?
    inputBinding:
      position: 4
      prefix: -matched
  outprefix:
    type: string

outputs:
  contamination_table:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).somatic.contamination.table
  tumor_segmentation:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).somatic.segments.table
  log:
    type: stderr

arguments:
  - position: 2
    valueFrom: CalculateContamination
  - position: 5
    prefix: -O
    valueFrom: $(inputs.outprefix).somatic.contamination.table
  - position: 6
    prefix: --tumor-segmentation
    valueFrom: $(inputs.outprefix).somatic.segments.table

stderr: $(inputs.outprefix).somatic.contamination.log

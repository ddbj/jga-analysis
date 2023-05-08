#!/usr/bin/env cwl-runner

class: CommandLineTool
id: MergeStats
label: MergeStats
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.4.0

baseCommand: [gatk, MergeMutectStats]

inputs:
  shifted_stats:
    type: File
    inputBinding:
      position: 1
      prefix: --stats
  non_shifted_stats:
    type: File
    inputBinding:
      position: 2
      prefix: --stats
  outprefix:
    type: string

outputs:
  stats:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).raw.combined.stats
  log:
    type: stderr

stderr: $(inputs.outprefix).raw.combined.stats.log

arguments:
  - position: 3
    prefix: -O
    valueFrom: $(inputs.outprefix).raw.combined.stats

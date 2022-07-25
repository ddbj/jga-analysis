#!/usr/bin/env cwl-runner

class: CommandLineTool
id: LearnReadOrientationModel
label: LearnReadOrientationModel
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
  f1r2_tar_gz:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 3
  outprefix:
    type: string

outputs:
  artifact_priors:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).somatic.artifact-priors.tar.gz
  log:
    type: stderr

arguments:
  - position: 2
    valueFrom: LearnReadOrientationModel
  - position: 4
    prefix: -O
    valueFrom: $(inputs.outprefix).somatic.artifact-priors.tar.gz

stderr: $(inputs.outprefix).somatic.artifact-priors.log

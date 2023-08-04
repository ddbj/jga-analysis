#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.2
baseCommand: jga-analysis-qc
requirements:
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.project_directory)
        writable: true
  DockerRequirement:
    dockerPull: ghcr.io/ddbj/jga-analysis-qc:1.0.0
arguments:
  - report
  - $(inputs.project_directory)
  - $(inputs.sample_list_yaml)
inputs:
  - id: project_directory
    type: Directory
  - id: sample_list_yaml
    type: File
  - id: no_show_path
    type: boolean
    default: true
    inputBinding:
      position: 10
      prefix: --no-show-path

outputs:
  - id: output
    type:
      type: array
      items: [File, Directory]
    outputBinding:
      glob: "*"


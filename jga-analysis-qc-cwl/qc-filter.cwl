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
  - filter
  - $(inputs.project_directory)
  - $(inputs.parameter_file)
inputs:
  - id: project_directory
    type: Directory
  - id: parameter_file
    type: File

outputs:
  - id: output
    type:
      type: array
      items: [File, Directory]
    outputBinding:
      glob: "*"


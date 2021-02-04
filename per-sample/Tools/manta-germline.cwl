#!/usr/bin/env cwl-runner

class: CommandLineTool
id: manta-germline
label: mainta-germline
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  ShellCommandRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entry: MantaWorkflow
        writable: true
  EnvVarRequirement:
    envDef:
      REFERENCE: $(inputs.reference.path)
      BAM: $(inputs.cram.path)
      CONFIG_MANTA_OPTION: $(inputs.config_manta_option)
      WORKFLOW_OPTION: $(inputs.workflow_option)

hints:
  DockerRequirement:
    dockerPull: ghcr.io/tafujino/jga-analysis/manta:latest

baseCommand: [bash, /tools/manta-germline.sh ]

inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
  cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
  config_manta_option:
    type: string
    default: ''
  workflow_option:
    type: string
    default: ''

outputs:
  log:
    type: stderr

stderr: $(inputs.cram.basename).vcf.log

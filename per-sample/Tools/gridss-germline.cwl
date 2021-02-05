#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gridss-germline
label: gridss-germline
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  EnvVarRequirement:
    envDef:
      JAVA_TOOL_OPTIONS: ''
  DockerRequirement:
    dockerPull: gridss/gridss:2.10.2
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.reference)
        writable: true # .gridsslock file should be created

baseCommand: [ /opt/gridss/gridss.sh ]

inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
    inputBinding:
      prefix: -r
      position: 4
  cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
    inputBinding:
      position: 1
  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: -t
      position: 5

outputs:
  log:
    type: stderr

stderr: $(inputs.cram.basename).vcf.log

arguments:
  - position: 2
    prefix: -o
    valueFrom: $(inputs.cram.nameroot).vcf
  - position: 2
    prefix: -a
    valueFrom: $(inputs.cram.nameroot).assembly.bam
  - position: 6
    prefix: --picardoptions
    valueFrom: VALIDATION_STRINGENCY=LENIENT
  - position: 7
    prefix: --workingdir
    valueFrom: $(runtime.outdir)

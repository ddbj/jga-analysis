#!/usr/bin/env cwl-runner

class: CommandLineTool
id: pdf2png
label: pdf2png
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: minidocks/poppler:0.56

baseCommand: [ pdftoppm ]

inputs:
  pdf:
    type: File
    format: edam:format_3508
    inputBinding:
      position: 1

outputs:
  png:
    type: stdout
    format: edam:format_3603

stdout: $(inputs.pdf.nameroot).png

arguments:
  - position: 2
    valueFrom: '-png'

#!/usr/bin/env cwl-runner

class: CommandLineTool
id: align
label: align
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
# baseCommand: python3
# arguments: ["$(which align.py)",
#             "--fastqs_R1", "~{sep=' ' fastqs_R1}",
#             "--fastqs_R2", "~{sep=' ' fastqs_R2}",
#             "--endedness", "~{endedness}",
#             "--index", "~{index}",
#             "~{"--bamroot " + bamroot}",
#             "~{"--ncpus " + ncpus}",
#             "~{"--ramGB " + ramGB}"]
baseCommand: [python3, align.py]
inputs:
  fastqs_R1:
    type: File[]
    inputBinding:
      position: 1
      prefix: --fastqs_R1
  fastqs_R2:
    type: File[]
    inputBinding:
      position: 2
      prefix: --fastqs_R2
  endedness:
    type: string
    inputBinding:
      position: 3
      prefix: --endedness
  index:
    type: File
    inputBinding:
      position: 4
      prefix: --index
  bamroot:
    type: string
    inputBinding:
      position: 5
      prefix: --bamroot
  ncpus:
    type: int
    inputBinding:
      position: 6
      prefix: --ncpus
  ramGB:
    type: int
    inputBinding:
      position: 7
      prefix: --ramGB
   
outputs:
    genomebam:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_genome.bam"
    annobam:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_anno.bam"
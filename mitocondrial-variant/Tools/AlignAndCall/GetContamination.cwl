#!/usr/bin/env cwl-runner

class: CommandLineTool
id: GetContamination
label: GetContamination
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: us.gcr.io/broad-dsde-methods/haplochecker:haplochecker-0124

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - class: File
        location: GetContamination.sh
      - $(inputs.vcf)

baseCommand: [/bin/bash, GetContamination.sh]

inputs:
  vcf:
    type: File
    format: edam:format_3016

outputs:
  contamination:
    type: File
    outputBinding:
      glob: output-noquotes
      # The output filename `output-noquotes` in the original WDL implementations is
      # obscure and gives no clue for the content. Thus we renamed it to more intuitive
      # name after running the shell script.
      # (An alternative choice is to modify the shell script itself.)
      outputEval: ${self[0].basename = inputs.vcf.nameroot + '.contamination_metrics'; return self;}
  hasContamination:
    type: string
    outputBinding:
      glob: contamination.txt
      loadContents: true
      outputEval: $(self[0].contents.trim())
  major_hg:
    type: string
    outputBinding:
      glob: major_hg.txt
      loadContents: true
      outputEval: $(self[0].contents.trim())
  minor_hg:
    type: string
    outputBinding:
      glob: minor_hg.txt
      loadContents: true
      outputEval: $(self[0].contents.trim())
  major_level:
    type: float
    outputBinding:
      glob: mean_het_major.txt
      loadContents: true
      outputEval: $(parseFloat(self[0].contents.trim()))
  minor_level:
    type: float
    outputBinding:
      glob: mean_het_minor.txt
      loadContents: true
      outputEval: $(parseFloat(self[0].contents.trim()))
  log:
    type: stderr

stderr: $(inputs.vcf.nameroot).contamination_metrics.log

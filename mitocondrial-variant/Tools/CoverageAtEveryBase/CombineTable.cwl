#!/usr/bin/env cwl-runner

class: CommandLineTool
id: CombineTable
label: CombineTable
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: us.gcr.io/broad-gotc-prod/genomes-in-the-cloud:2.4.2-1552931386

requirements:
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.non_control_region)
        entryname: non_control_region.tsv
      - entry: $(inputs.control_region_shifted)
        entryname: control_region_shifted.tsv
      - class: File
        location: CombineTable.R

baseCommand: [Rscript, --vanilla, CombineTable.R]

inputs:
  non_control_region:
    type: File
    format: edam:format_3475
  control_region_shifted:
    type: File
    format: edam:format_3475
  outprefix:
    type: string

outputs:
  per_base_coverage:
    type: File
    format: edam:format_3475
    outputBinding:
      glob: per_base_coverage.tsv
      outputEval: ${self[0].basename = inputs.outprefix + '.per_base_coverage.tsv'; return self;}
  log:
    type: stderr

stderr: $(inputs.outprefix).per_base_coverage.log

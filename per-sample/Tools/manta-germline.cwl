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
  alignmentStatsSummary:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/stats/alignmentStatsSummary.txt
  svCandidateGenerationStats_tsv:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/stats/svCandidateGenerationStats.tsv
  svCandidateGenerationStats_xml:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/stats/svCandidateGenerationStats.xml
  svLocusGraphStats_tsv:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/stats/svLocusGraphStats.tsv
  candidateSV_vcf_gz:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/variants/candidateSV.vcf.gz
  candidateSV_vcf_gz_tbi:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/variants/candidateSV.vcf.gz.tbi
  candidateSmallIndels_vcf_gz:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz
  candidateSmallIndels_vcf_gz_tbi:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz.tbi
  diploidSV_vcf_gz:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/variants/diploidSV.vcf.gz
  diploidSV_vcf_gz_tbi:
    type: File
    outputBinding:
      glob: MantaWorkflow/results/variants/diploidSV.vcf.gz.tbi
  log:
    type: stderr

stderr: $(inputs.cram.basename).vcf.log

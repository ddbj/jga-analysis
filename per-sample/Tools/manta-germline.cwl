#!/usr/bin/env cwl-runner

class: CommandLineTool
id: manta-germline
label: mainta-germline
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/tafujino/jga-analysis/manta:latest
  ShellCommandRequirement: {}
  EnvVarRequirement:
    envDef:
      REFERENCE: $(inputs.reference.path)
      BAM: $(inputs.cram.path)
      NUM_THREADS: $(inputs.num_threads)
      CONFIG_MANTA_OPTION: $(inputs.config_manta_option)
      WORKFLOW_OPTION: $(inputs.workflow_option)

baseCommand: [ bash, /tools/manta-germline.sh ]

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
  num_threads:
    type: int
    default: 1
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
    format: edam:format_3475
    outputBinding:
      glob: MantaWorkflow/results/stats/svCandidateGenerationStats.tsv
  svCandidateGenerationStats_xml:
    type: File
    format: edam:format_2332
    outputBinding:
      glob: MantaWorkflow/results/stats/svCandidateGenerationStats.xml
  svLocusGraphStats_tsv:
    type: File
    format: edam:format_3475
    outputBinding:
      glob: MantaWorkflow/results/stats/svLocusGraphStats.tsv
  candidateSV_vcf_gz:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: MantaWorkflow/results/variants/candidateSV.vcf.gz
  candidateSV_vcf_gz_tbi:
    type: File
    format: format_3700
    outputBinding:
      glob: MantaWorkflow/results/variants/candidateSV.vcf.gz.tbi
  candidateSmallIndels_vcf_gz:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz
  candidateSmallIndels_vcf_gz_tbi:
    type: File
    format: format_3700
    outputBinding:
      glob: MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz.tbi
  diploidSV_vcf_gz:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: MantaWorkflow/results/variants/diploidSV.vcf.gz
  diploidSV_vcf_gz_tbi:
    type: File
    format: format_3700
    outputBinding:
      glob: MantaWorkflow/results/variants/diploidSV.vcf.gz.tbi
  log:
    type: stderr

stderr: $(inputs.cram.basename).manta.log

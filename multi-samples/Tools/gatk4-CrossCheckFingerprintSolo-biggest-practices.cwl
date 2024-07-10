#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-CrossCheckFingerprintSolo-biggest-practices
label: gatk4-CrossCheckFingerprintSolo-biggest-practices
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.gvcf_dir)
      - entry: $(inputs.vcf_dir)

baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    default: -Xms122368m -Xmx122368m
    doc: default is 100gvcfs
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  gvcf_inputs_list:
    type: File
    inputBinding:
      position: 3
      prefix: --INPUT
  vcf_inputs_list:
    type: File
    inputBinding:
      position: 4
      prefix: --SECOND_INPUT
  haplotype_database:
    type: File
    inputBinding:
      position: 5
      prefix: --HAPLOTYPE_MAP
  sample_name_map:
    type: File
    inputBinding:
      position: 6
      prefix: --INPUT_SAMPLE_FILE_MAP
  cpu:
    type: int
    default: 32
    inputBinding:
      prefix: --NUM_THREADS
      position: 9
  scattered:
    type: boolean
    default: false
    inputBinding:
      position: 10
      prefix: --EXIT_CODE_WHEN_MISMATCH 0
      shellQuote: false
  callset_name:
    type: string
    doc: (ex) gnarly_callset
  gvcf_dir:
    type: Directory
  vcf_dir:
    type: Directory


outputs:
  crosscheck_metrics:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).fingerprintcheck

stderr: $(inputs.callset_name).fingerprintcheck.log

arguments:
  - position: 2
    valueFrom: CrosscheckFingerprints
  - position: 7
    valueFrom: --CROSSCHECK_BY SAMPLE
    shellQuote: false
  - position: 8
    valueFrom: --CROSSCHECK_MODE CHECK_SAME_SAMPLE
    shellQuote: false
  - position: 11
    prefix: --OUTPUT
    valueFrom: $(inputs.callset_name).fingerprintcheck
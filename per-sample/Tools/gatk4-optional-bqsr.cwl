#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-optional-bqsr
label: gatk4-optional-bqsr
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/ddbj/jga-analysis/fastq2cram-bqsr-haplotypecaller:1.0.0
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      USE_BQSR: "$(inputs.use_bqsr ? 'true' : 'false')"
      REFERENCE: $(inputs.reference.path)
      BAM: $(inputs.bam.path)
      USE_ORIGINAL_QUALITIES: $(inputs.use_original_qualities)
      GATK4_BASE_RECALIBRATOR_JAVA_OPTIONS: $(inputs.gatk4_BaseRecalibrator_java_options)
      GATK4_APPLY_BQSR_JAVA_OPTIONS: $(inputs.gatk4_ApplyBQSR_java_options)
      DBSNP: $(inputs.dbsnp.path)
      MILLS: $(inputs.mills.path)
      KNOWN_INDELS: $(inputs.known_indels.path)
      STATIC_QUANTIZED_QUALS_OPTIONS: |
        $(
          inputs.static_quantized_quals.map(
            function(x) { '--static-quantized-quals ' + String(x) }
          ).join(' ')
        )
      OUT_PREFIX: $(inputs.outprefix)

baseCommand: [ bash, /tools/optional-bqsr.sh ]

inputs:
  use_bqsr:
    type: boolean
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - ^.dict
  bam:
    type: File
    format: edam:format_2572
    doc: A BAM file containing sequencing reads
  use_original_qualities:
    type: string
    doc: true or false
    default: "false"
  gatk4_BaseRecalibrator_java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx4g -Xms4g
  gatk4_ApplyBQSR_java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx3g -Xms3g
  dbsnp:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    doc: Homo_sapiens_assembly38.dbsnp138.vcf
  mills:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
  known_indels:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Homo_sapiens_assembly38.known_indels.vcf.gz
  static_quantized_quals:
    type:
      type: array
      items: int
    default: [10, 20, 30]
    doc: Use static quantized quality scores to a given number of levels (with -bqsr)
  outprefix:
    type: string

outputs:
  out_bam:
    type: File
    format: edam:format_2572
    outputBinding:
      glob: $(inputs.outprefix).bam
    secondaryFiles:
      - ^.bai
  table:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).recal_data.table
  log:
    type: stderr

stderr: $(inputs.outprefix).bam.log

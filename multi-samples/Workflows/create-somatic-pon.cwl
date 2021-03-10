#!/usr/bin/env cwl-runner

class: Workflow
id: create-somatic-pon
label: create-somatic-pon
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  - class: StepInputExpressionRequirement
  
inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict

  germline_resource:
    type: File
    format: edam:format_3016
    doc: Population vcf of germline sequencing containing allele fractions.
    secondaryFiles:
      - .tbi
      
  gvcfs:
    type:
      type: array
      items: File
    doc: gVCF files to be imported
    secondaryFiles:
      - .tbi

  interval_bed:
    type: File
    format: edam:format_3584

  outprefix:
    type: string
    
  genomicsDB_batch_size:
    type: int
    default: 0

  genomicsDB_interval_padding:
    type: int
    default: 0
    
  gatk4-GenomicsDBImport_java_options:
    type: string?
    
  gatk4-GenomicsDBImport_num_threads:
    type: int
    default: 1

  gatk4-CreateSomaticPanelOfNormals_java_options:
    type: string?

steps:
  gatk4-GenomicsDBImport:
    label: gatk4-GenomicsDBImport
    doc: Import gVCFs into genomics DB
    run: ../Tools/gatk4-GenomicsDBImport.cwl
    in:
      in_gVCFs: gvcfs
      outprefix: outprefix
      interval_bed: interval_bed
      batch_size: genomicsDB_batch_size
      interval_padding: genomicsDB_interval_padding
      num_threads: gatk4-GenomicsDBImport_num_threads
      java_options: gatk4-GenomicsDBImport_java_options
    out:
      [genomics-db, log]

  gatk4-CreateSomaticPanelOfNormals:
    label: gatk4-CreateSomaticPanelOfNormals
    doc: Make a panel of normals for use with Mutect2
    run: ../Tools/gatk4-CreateSomaticPanelOfNormals.cwl
    in:
      reference: reference
      germline_resource: germline_resource
      genomicsDB: gatk4-GenomicsDBImport/genomics-db
      outprefix: outprefix
      java_options: gatk4-CreateSomaticPanelOfNormals_java_options
    out:
      [vcf, log]

outputs:
  vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    outputSource: gatk4-CreateSomaticPanelOfNormals/vcf

  genomics-db_log:
    type: File
    outputSource: gatk4-GenomicsDBImport/log

  create-pon_log:
    type: File
    outputSource: gatk4-CreateSomaticPanelOfNormals/log


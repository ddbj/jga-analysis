#!/usr/bin/env cwl-runner

class: Workflow
id: multisamples
label: multisamples
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  ResourceRequirement:
    outdirMin: 40960
    tmpdirMin: 65536
    ramMin: 65536
    coresMin: 8
inputs:
  sample_set:
    type: string
  interval_type:
    type: string
  
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict


  dbsnp:
    type: File
    format: edam:format_3016
    doc: A dbSNP VCF file.
    secondaryFiles:
      - .idx

  # gvcfs:
  #   type:
  #     type: array
  #     items: File
  #   doc: gVCF files to be imported
  #   secondaryFiles:
  #     - .tbi
  gvcfs_dir:
    type: Directory

  interval_bed_list:
    type:
      type: array
      items:
        - type: record
          fields:

            interval_bed:
              type: File
              format: edam:format_3584


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

  gatk4-GenotypeGVCFs_java_options:
    type: string?

  gatk4-VariantFiltration_java_options:
    type: string?

  gatk4-MakeSitesOnlyVcf_java_options:
    type: string?

## 
  gathervcfs_outprefix:
    type: string

  gatk4-GatherVcfs_java_options:
    type: string?

steps:
  joint-variant-calling:
    run: ./joint-variant-calling_gvcfs_dir.cwl
    scatter: interval_bed
    in:
      sample_set: sample_set
      interval_type: interval_type
      #
      reference: reference
      dbsnp: dbsnp
      # gvcfs: gvcfs
      gvcfs_dir: gvcfs_dir
      # interval_bed: interval_bed
      genomicsDB_batch_size: genomicsDB_batch_size
      genomicsDB_interval_padding: genomicsDB_interval_padding
      # echo "outprefix: $sample_set.$interval_type.$interval_name" >> $jobfile
      # PASS.autosome_PAR_ploidy_2.
      # outprefix: outprefix
      gatk4-GenomicsDBImport_java_options: gatk4-GenomicsDBImport_java_options
      gatk4-GenomicsDBImport_num_threads: gatk4-GenomicsDBImport_num_threads
      gatk4-GenotypeGVCFs_java_options: gatk4-GenotypeGVCFs_java_options
      gatk4-VariantFiltration_java_options: gatk4-VariantFiltration_java_options
      gatk4-MakeSitesOnlyVcf_java_options: gatk4-MakeSitesOnlyVcf_java_options

      interval_bed:
        source: interval_bed_list
        valueFrom: $(self.interval_bed)
      outprefix:
        valueFrom: $(inputs.sample_set+"."+inputs.interval_type+"."+inputs.interval_bed.interval_bed.basename)
    out:
      - genomics-db
      - vcf
      - sites_only_vcf
      - genomics-db_log
      - joint-call_vcf
      - joint-call_log
      - filter-ExcessHet_log
      - sites-only_log

  gathervcfs:
    run: ../Tools/gatk4-GatherVcfs.cwl
    in:
      vcfs: joint-variant-calling/vcf
      outprefix: gathervcfs_outprefix
      java_options: gatk4-GatherVcfs_java_options
    out:
      - gathered_vcf
      - log

outputs:
##
  genomics-db:
    type: Directory[]
    outputSource: joint-variant-calling/genomics-db

  vcf:
    type: File[]
    format: edam:format_3016
    secondaryFiles:
      - .idx
    outputSource: joint-variant-calling/vcf

  sites_only_vcf:
    type: File[]
    format: edam:format_3016
    secondaryFiles:
      - .idx
    outputSource: joint-variant-calling/sites_only_vcf

  genomics-db_log:
    type: File[]
    outputSource: joint-variant-calling/genomics-db_log

  joint-call_vcf:
    type: File[]
    format: edam:format_3016
    secondaryFiles:
      - .idx
    outputSource: joint-variant-calling/joint-call_vcf

  joint-call_log:
    type: File[]
    outputSource: joint-variant-calling/joint-call_log

  filter-ExcessHet_log:
    type: File[]
    outputSource: joint-variant-calling/filter-ExcessHet_log

  sites-only_log:
    type: File[]
    outputSource: joint-variant-calling/sites-only_log


##
      
  gathered_vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    outputSource: gathervcfs/gathered_vcf


  gathered_vcf_log:
    type: File
    outputSource: gathervcfs/log


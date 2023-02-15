#!/usr/bin/env cwl-runner

class: Workflow
id: joint-varinat-calling
label: joint-variant-calling
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

  interval_bed:
    type: File
    format: edam:format_3584

  genomicsDB_batch_size:
    type: int
    default: 0

  genomicsDB_interval_padding:
    type: int
    default: 0
    
  outprefix:
    type: string
    
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
    
steps:
  gatk4-GenomicsDBImport:
    label: gatk4-GenomicsDBImport
    doc: Import gVCFs into genomics DB
    run: ../Tools/gatk4-GenomicsDBImport_from_directory.cwl
    in:
      # in_gVCFs: gvcfs
      in_gVCFs_dir: gvcfs_dir
      outprefix: outprefix
      interval_bed: interval_bed
      batch_size: genomicsDB_batch_size
      interval_padding: genomicsDB_interval_padding
      num_threads: gatk4-GenomicsDBImport_num_threads
      java_options: gatk4-GenomicsDBImport_java_options
    out:
      [genomics-db, log]

  gatk4-GenotypeGVCFs:
    label: gatk4-GenotypeGVCFs
    doc: Joint varinat calling from gVCFs
    run: ../Tools/gatk4-GenotypeGVCFs.cwl
    in:
      reference: reference
      dbsnp: dbsnp
      genomicsDB: gatk4-GenomicsDBImport/genomics-db
      interval_bed: interval_bed
      outprefix:
        source: outprefix
        valueFrom: $(inputs.outprefix).gatk4-GenotypeGVCFs
      java_options: gatk4-GenotypeGVCFs_java_options
    out:
      [vcf, log]

  gatk4-VariantFiltration:
    label: gatk4-VariantFiltration
    doc: Filter variants based on ExcessHet
    run: ../Tools/gatk4-VariantFiltration.cwl
    in:
      vcf: gatk4-GenotypeGVCFs/vcf
      outprefix: outprefix
      java_options: gatk4-VariantFiltration_java_options
    out:
      [vcf, log]

  gatk4-MakeSitesOnlyVcf:
    label: gatk4-MakeSitesOnlyVcf
    doc: Make sites-only vcf
    run: ../Tools/gatk4-MakeSitesOnlyVcf.cwl
    in:
      vcf: gatk4-GenotypeGVCFs/vcf
      outprefix:
        source: outprefix
        valueFrom: $(inputs.outprefix).sites-only
      java_options: gatk4-MakeSitesOnlyVcf_java_options
    out:
      [sites_only_vcf, log]

outputs:
  genomics-db:
    type: Directory
    outputSource: gatk4-GenomicsDBImport/genomics-db

  vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    outputSource: gatk4-VariantFiltration/vcf

  sites_only_vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    outputSource: gatk4-MakeSitesOnlyVcf/sites_only_vcf
    
  genomics-db_log:
    type: File
    outputSource: gatk4-GenomicsDBImport/log

  joint-call_log:
    type: File
    outputSource: gatk4-GenotypeGVCFs/log

  filter-ExcessHet_log:
    type: File
    outputSource: gatk4-VariantFiltration/log

  sites-only_log:
    type: File
    outputSource: gatk4-MakeSitesOnlyVcf/log

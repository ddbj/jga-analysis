#!/usr/bin/env cwl-runner

class: Workflow
id: vcf.gz2bed
label: vcf.gz2bed
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

inputs:
  vcf_gz:
    type: File
    format: edam:format_3016
    doc: A VCF.GZ file containing variants

  outprefix:
    type: string    

steps:
  bedops-vcf.gz2vcf:
    label: bedops-vcf.gz2vcf
    doc: Convert VCF.GZ to VCF
    run: ../Tools/bedops-vcf.gz2vcf.cwl
    in:
      gz: vcf_gz
      outprefix: outprefix
    out:
      [out, log]

  bedops-vcf2bed:
    label: bedops-vcf2bed
    doc: Convert VCF to BED
    run: ../Tools/bedops-vcf2bed.cwl
    in:
      vcf: bedops-vcf.gz2vcf/out
      outprefix: outprefix
    out:
      [bed, log]

outputs:
  bed:
    type: File
    format: edam:format_3584
    outputSource: bedops-vcf2bed/bed

  bedops-vcf.gz2vcf_log:
    type: File
    outputSource: bedops-vcf.gz2vcf/log

  bedops-vcf2bed_log:
    type: File
    outputSource: bedops-vcf2bed/log


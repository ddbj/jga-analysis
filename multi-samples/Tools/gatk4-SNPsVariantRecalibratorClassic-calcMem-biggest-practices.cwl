#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-SNPsVariantRecalibratorClassic-calcMem-biggest-practices
label: gatk4-SNPsVariantRecalibratorClassic-calcMem-biggest-practices
cwlVersion: v1.1

cwlVersion: v1.2
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0

baseCommand: [bash]

inputs:
  sh:
    type: File
    inputBinding:
      position: 1
  sites_only_variant_filtered_vcf:
    type: File
    inputBinding:
      position: 2
  hapmap_resource_vcf:
    type: File
    inputBinding:
      position: 3
  omni_resource_vcf:
    type: File
    inputBinding:
      position: 4
  one_thousand_genomes_resource_vcf:
    type: File
    inputBinding:
      position: 5
  dbsnp_resource_vcf:
    type: File
    inputBinding:
      position: 6
  machine_mem_mb:
    type: int?
    inputBinding:
      position: 7

outputs:
  auto_mem:
    type: int
    outputBinding:
      glob: stdout
      loadContents: true
      outputEval: $(self.contents.match(/auto_mem: (\d+)/)[1])
  machine_mem:
    type: int
    outputBinding:
      glob: stdout
      loadContents: true
      outputEval: $(self.contents.match(/machine_mem: (\d+)/)[1])
  java_mem:
    type: int
    outputBinding:
      glob: stdout
      loadContents: true
      outputEval: $(self.contents.match(/java_mem: (\d+)/)[1])
  max_heap:
    type: int
    outputBinding:
      glob: stdout
      loadContents: true
      outputEval: $(self.contents.match(/max_heap: (\d+)/)[1])



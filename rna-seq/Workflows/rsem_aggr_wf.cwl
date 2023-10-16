 #!/usr/bin/env cwl-runner
 
 class: Workflow
 id: rsem_aggr_wf
 label: rsem_aggregate
 cwlVersion: v1.2
 
 requirements:
   StepInputExpressionRequirement: {}
 
 inputs:
   sh_rsem:
     type: File
   rsem_isoforms:
     type: File[]
   rsem_genes:
     type: File[]
   prefix_rsem:
     type: string
 
 steps:
   rsem_aggr:
     run: ../Tools/rsem_aggr.cwl
     in:
       sh_rsem: sh_rsem
       rsem_isoforms: rsem_isoforms
       rsem_genes: rsem_genes
       prefix_rsem: prefix_rsem
     out:
       - transcripts_tpm
       - transcripts_isopct
       - transcripts_expected_count
       - genes_tpm
       - genes_expected_count
 
 outputs:
   transcripts_tpm:
     type: File
     outputSource: rsem_aggr/transcripts_tpm
   transcripts_isopct:
     type: File
     outputSource: rsem_aggr/transcripts_isopct
   transcripts_expected_count:
     type: File
     outputSource: rsem_aggr/transcripts_expected_count
   genes_tpm:
     type: File
     outputSource: rsem_aggr/genes_tpm
   genes_expected_count:
     type: File
     outputSource: rsem_aggr/genes_expected_count
# rna-seq-wf
## rna-seq-pipeline-per-sample
- reference data download
  - align_index
    ```
    wget https://www.encodeproject.org/files/ENCFF598IDH/@@download/ENCFF598IDH.tar.gz
    ```
  - rsem_index
    ```
    wget https://www.encodeproject.org/files/ENCFF285DRD/@@download/ENCFF285DRD.tar.gz
    ```
  - chrom_sizes
    ```
    wget https://www.encodeproject.org/files/GRCh38_EBV.chrom.sizes/@@download/GRCh38_EBV.chrom.sizes.tsv
    ```
  - tr_id_to_gene_type_tsv
    ```
    wget https://raw.githubusercontent.com/hacchy1983/rna-seq-pipeline/dev/transcript_id_to_gene_type_mappings/gencodeV29pri-UCSC-tRNAs-ERCC-phiX.transcript_id_to_genes.tsv
    ```
- Command
   - pairend
     ```
     cwltool --singularity rna-seq/Workflows/rna-seq-pipeline-per-sample_PE.cwl rna-seq/Workflows/input_rna-seq-pipeline-per-sample_PE.yaml
     ```
   - singlend
     ``` 
     cwltool --singularity rna-seq/Workflows/rna-seq-pipeline-per-sample_SE.cwl rna-seq/Workflows/input_rna-seq-pipeline-per-sample_SE.yaml
     ```

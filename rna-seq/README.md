# JGA analysis rna-seq workflow
This workflow consists of the following steps:
- Alignment (FASTQ to BAM): STAR (version [2.5.1b](https://github.com/alexdobin/STAR/releases/tag/2.5.1b))
- STATS(Samtools flagstat): samtools flagstat (version [1.9](https://github.com/samtools/samtools/releases/tag/1.9))
- Check(Check aligned BAM): samtools quickcheck (version [1.9](https://github.com/samtools/samtools/releases/tag/1.9))
- Convert（aligned BAM to bigwig）: STAR (version [2.5.1b](https://github.com/alexdobin/STAR/releases/tag/2.5.1b))
- Quantification: RSEM (version [v1.2.31](https://github.com/deweylab/RSEM/releases/tag/v1.2.31))
- RNA QC: qc-utils (version [19.8.1](https://qc-utils.readthedocs.io/en/latest/))

This workflow was converted to CWL code by referring to  [rna-seq-pipeline-per-sample.wdl](https://github.com/hacchy1983/rna-seq-pipeline/blob/dev/rna-seq-pipeline-per-sample.wdl)

## Data required to run workflows
- Reference Data Download Methods
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

## Execute the per-sample workflow
### Usage
- paired（PE）
  ```console
  cwltool --singularity rna-seq/Workflows/rna-seq-pipeline-per-sample_PE.cwl PE.yaml
  ```
- single（SE）
  ```console
  cwltool --singularity rna-seq/Workflows/rna-seq-pipeline-per-sample_SE.cwl SE.yaml
  ```

  If temporary directory is specified(`/data/usr/temp`) and singularity does not mount it by default, use following.
- paired（PE）
  ```console
  SINGULARITY_BIND=/data/usr/temp cwltool --outdir output/ --singularity rna-seq/Workflows/rna-seq-pipeline-per-sample_PE.cwl PE.yaml
  ```
- single（SE）
  ```console
  SINGULARITY_BIND=/data/usr/temp cwltool --outdir output/ --singularity rna-seq/Workflows/rna-seq-pipeline-per-sample_SE.cwl SE.yaml
  ```

### Job file
#### paired（PE）
- Let a sample job file be `PE.yaml` in pair-end case. 
- Please specify TOPDIR to be a referece data top directory.

```yaml
endedness: "paired"
bamroot: "sample_id"
index:
    class: File
    path: "TOPDIR/ENCFF598IDH.tar.gz"
fastqs_R1:
  - class: File
    path: "TOPDIR/ENCSR653DFZ_rep1_chr19_10000reads_R1.fastq.gz"
  - class: File
    path: "TOPDIR/ENCSR653DFZ_rep2_chr19_10000reads_R1.fastq.gz"
fastqs_R2:
  - class: File
    path: "TOPDIR/ENCSR653DFZ_rep1_chr19_10000reads_R2.fastq.gz" 
  - class: File
    path: "TOPDIR/ENCSR653DFZ_rep2_chr19_10000reads_R2.fastq.gz"
ramGB: 4
ncpus: 2
chrom_sizes:
    class: File
    path: "TOPDIR/GRCh38_EBV.chrom.sizes.tsv"
strandedness: "stranded"
rsem_index:
    class: File
    path: "TOPDIR/ENCFF285DRD.tar.gz"
rnd_seed: 12345
read_strand: "reverse"
tr_id_to_gene_type_tsv:
    class: File
    path: "TOPDIR/gencodeV29pri-UCSC-tRNAs-ERCC-phiX.transcript_id_to_genes.tsv"

```

#### single（SE）
- Let a sample job file be `SE.yaml` in single-end case. 
- Please specify TOPDIR to be a referece data top directory.

```yaml
endedness: "single"
bamroot: "sample_id"
index:
    class: File
    path: "TOPDIR/ENCFF598IDH.tar.gz"
fastqs_R1:
  - class: File
    path: "TOPDIR/ENCSR653DFZ_rep1_chr19_10000reads_R1.fastq.gz"
  - class: File
    path: "TOPDIR/ENCSR653DFZ_rep2_chr19_10000reads_R1.fastq.gz"
ramGB: 4
ncpus: 2
chrom_sizes:
    class: File
    path: "TOPDIR/GRCh38_EBV.chrom.sizes.tsv"
strandedness: "stranded"
rsem_index:
    class: File
    path: "TOPDIR/ENCFF285DRD.tar.gz"
rnd_seed: 12345
read_strand: "reverse"
tr_id_to_gene_type_tsv:
    class: File
    path: "TOPDIR/gencodeV29pri-UCSC-tRNAs-ERCC-phiX.transcript_id_to_genes.tsv"

```
# JGA analysis RSEM_aggregate workflow
This workflow consists of the following steps:
- Merge rna-seq workflow results : [aggregate_rsem_results.py](https://github.com/hacchy1983/depmap_omics_RSEM_aggregate/blob/master/RNA_pipeline/aggregate_rsem_results.py)

This workflow was converted to CWL code by referring to [rsem_aggregate_results.wdl](https://github.com/hacchy1983/depmap_omics_RSEM_aggregate/blob/master/RNA_pipeline/rsem_aggregate_results.wdl)
## Execute the RSEM_aggregate workflow
### Usage
  ```console
  cwltool --singularity jga-analysis/rna-seq/Workflows/rsem_aggr_wf.cwl input.yaml
  ```

### Job file
- Let a sample job file be input.yaml 
- The rsem_isoforms and rsem_genes are the results of running the "rna-seq workflow" on different samples.
- Please specify TOPDIR to be a referece data top directory.

```yaml
sh_rsem:
    class: File
    path: "TOPDIR/jga-analysis/rna-seq/Tools/rsem_aggr.sh"
rsem_isoforms:
  - class: File
    path: "TOPDIR/sample_1_anno_rsem.isoforms.results"
  - class: File
    path: "TOPDIR/sample_2_anno_rsem.isoforms.results"
rsem_genes:
  - class: File
    path: "TOPDIR/sample_1_anno_rsem.genes.results"
  - class: File
    path: "TOPDIR/sample_2_anno_rsem.genes.results"
prefix_rsem: "sample_set_id"

```
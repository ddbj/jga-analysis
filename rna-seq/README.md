# JGA analysis per-sample workflow

This is the ENCODE-DCC RNA-sequencing pipeline. The scope of the pipeline is to align reads, generate signal tracks, and quantify genes and isoforms.This repository is a CWL language conversion of [rna-seq-pipeline/rna-seq-pipeline-per-sample.wdl](https://github.com/hacchy1983/rna-seq-pipeline/blob/dev/rna-seq-pipeline-per-sample.wdl). Inputs and tools are summarized in the [REFERENCE](https://github.com/hacchy1983/rna-seq-pipeline/blob/dev/docs/reference.md)

This workflow consists of the following steps:
- Alignment (FASTQ to BAM): STAR (version [2.5.1b](https://github.com/alexdobin/STAR/releases/tag/2.5.1b))
- STATS(Samtools flagstat): samtools flagstat (version [1.9](https://github.com/samtools/samtools/releases/tag/1.9))
- Check(Check aligned BAM): samtools quickcheck (version [1.9](https://github.com/samtools/samtools/releases/tag/1.9))
- Convert（aligned BAM to bigwig）: STAR (version [2.5.1b](https://github.com/alexdobin/STAR/releases/tag/2.5.1b))
- Quantification: RSEM (version [v1.2.31](https://github.com/deweylab/RSEM/releases/tag/v1.2.31))
- RNA QC: qc-utils (version [19.8.1](https://qc-utils.readthedocs.io/en/latest/))

## Recommendations
- Memory >= 64GB
- Threads >= 16
- Disk space >= 100GB per sample

## Set up execution environments

Install CWL execution engine on your Server
- cwltool 3.1.20210816212154
  - execution on single machine

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
bamroot: "PE_stranded"
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
bamroot: "SE_stranded"
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
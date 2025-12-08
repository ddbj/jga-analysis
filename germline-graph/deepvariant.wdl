version 1.0

task Deepvariant {
  input {
    File bam
    File bam_bai
    File ref_fa
    File ref_fa_fai
    String make_examples_extra_args = "min_mapping_quality=0,keep_legacy_allele_counter_behavior=true,normalize_reads=true"
    Int num_cpus = 32
  }

  String vcf_basename = basename(bam, ".bam")

  command <<<
    ln -s ~{bam} .
    ln -s ~{bam_bai} .
    ln -s ~{ref_fa} .
    ln -s ~{ref_fa_fai} .

    date

    /opt/deepvariant/bin/run_deepvariant \
      --model_type=WGS \
      --ref=~{basename(ref_fa)} \
      --reads=~{basename(bam)} \
      --output_vcf=~{vcf_basename}.vcf.gz \
      --output_gvcf=~{vcf_basename}.g.vcf.gz \
      --make_examples_extra_args="~{make_examples_extra_args}" \
      --num_shards=~{num_cpus}

    date
  >>>

  output {
    File vcf_gz = "~{vcf_basename}.vcf.gz"
    File vcf_gz_tbi = "~{vcf_basename}.vcf.gz.tbi"
    File gvcf_gz = "~{vcf_basename}.g.vcf.gz"
    File gvcf_gz_tbi = "~{vcf_basename}.g.vcf.gz.tbi"
  }

  runtime {
    cpu: num_cpus
    memory: "64 GB"
    docker: "google/deepvariant:1.9.0"
  }
}

version 1.0

task Happy {
  input {
    File comparison_vcf_gz
    File comparison_vcf_gz_tbi
    File baseline_vcf_gz
    File baseline_vcf_gz_tbi
    File baseline_bed
    File ref_fa
    File ref_fa_fai
    Int num_cpus = 8
  }

  String out_prefix = "happy"

  command <<<
    ln -s ~{comparison_vcf_gz} .
    ln -s ~{comparison_vcf_gz_tbi} .
    ln -s ~{baseline_vcf_gz} .
    ln -s ~{baseline_vcf_gz_tbi} .
    ln -s ~{ref_fa} .
    ln -s ~{ref_fa_fai} .

    time \
      /opt/hap.py/bin/hap.py \
        ~{baseline_vcf_gz} \
        ~{comparison_vcf_gz} \
        -f ~{baseline_bed} \
        -r ~{ref_fa} \
        -o ~{out_prefix} \
        --engine=vcfeval \
        --pass-only \
        --threads ~{num_cpus}
  >>>

  output {
    File summary = "~{out_prefix}.summary.csv"
  }

  runtime {
    cpu: num_cpus
    memory: "64 GB"
    docker: "jmcdani20/hap.py:v0.3.12"
  }
}

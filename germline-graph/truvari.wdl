version 1.0

################################################################################
## task TruvariBench

task TruvariBench {
  input {
    File comparison_vcf_gz
    File comparison_vcf_gz_tbi
    File baseline_vcf_gz
    File baseline_vcf_gz_tbi
    File baseline_bed
    File ref_fa
  }

  command <<<
    ln -s ~{comparison_vcf_gz} .
    ln -s ~{comparison_vcf_gz_tbi} .
    ln -s ~{baseline_vcf_gz} .
    ln -s ~{baseline_vcf_gz_tbi} .

    /usr/bin/time -v \
      truvari bench \
        -b ~{basename(baseline_vcf_gz)} \
        -c ~{basename(comparison_vcf_gz)} \
        -f ~{ref_fa} \
        --includebed ~{baseline_bed} \
        -O 0.0 -r 1000 -p 0.0 -P 0.3 -C 1000 -s 50 -S 15 --sizemax 100000 --multimatch --no-ref c \
        -o out
  >>>

  output {
    File tp_base_vcf = "out/tp-base.vcf"
    File tp_call_vcf = "out/tp-call.vcf"
    File fp_vcf = "out/fp.vcf"
    File fn_vcf = "out/fn.vcf"
    File summary = "out/summary.txt"
  }

  runtime {
    memory: "16 GB"
    docker: "quay.io/biocontainers/truvari:3.5.0--pyhdfd78af_0"
  }
}

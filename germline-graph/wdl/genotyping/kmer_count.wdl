version 1.0

task KmerCount {
  input {
    File read1_fq
    File read2_fq
    Int kmer_size = 29
    Int num_cpus = 32
    Int mem_gb = 128
  }

  command <<<
    echo ~{read1_fq} > reads.lst
    echo ~{read2_fq} >> reads.lst

    /usr/bin/time -v \
      kmc -k~{kmer_size} -m~{mem_gb} -okff -t~{num_cpus} @reads.lst count "$(mktemp -d -p /tmp)"
  >>>

  output {
    File kff = "count.kff"
  }

  runtime {
    cpu: num_cpus
    memory: "~{mem_gb} GB"
    docker: "quay.io/biocontainers/kmc:3.2.4--h6dccd9a_0"
  }
}

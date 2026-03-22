version 1.0

################################################################################
# workflow GamToSortedBam

workflow GamToSortedBam {
  input {
    File gam
    String ref_name
    File ref_path
    File gbz
  }

  call VgSurject {
    input:
    gam = gam,
    gbz = gbz,
    ref_path = ref_path
  }

  call ReheaderBam {
    input:
    in_bam = VgSurject.bam,
    ref_name = ref_name
  }

  call SortBam {
    input:
    in_bam = ReheaderBam.out_bam
  }

  call IndexBam {
    input:
    bam = SortBam.out_bam
  }

  output {
    File bam = SortBam.out_bam
    File bam_bai = IndexBam.bam_bai
  }
}

################################################################################
# task VgSurject

task VgSurject {
  input {
    File gam
    File ref_path
    File gbz
    Int num_cpus = 32
  }

  String bam_filename = '~{basename(gam, ".gam")}.bam'

  command <<<
    /usr/bin/time -v \
      vg surject \
        -b \
        -x ~{gbz} \
        ~{gam} \
        -F ~{ref_path} \
        --prune-low-cplx \
        --interleaved \
        --max-frag-len 3000 \
        -t ~{num_cpus} \
        > ~{bam_filename}
  >>>

  output {
    File bam = bam_filename
  }

  runtime {
    cpu: num_cpus
    memory: "16 GB"
    docker: "quay.io/vgteam/vg:v1.68.0"
  }
}

################################################################################
# task ReheaderBam

task ReheaderBam {
  input {
    File in_bam
    String ref_name
  }

  String out_bam_filename = '~{basename(in_bam, ".bam")}.reheadered.bam'

  command <<<
    /usr/bin/time -v \
      samtools reheader -c "sed s/~{ref_name}#0#//g" ~{in_bam} > ~{out_bam_filename}
  >>>

  output {
    File out_bam = out_bam_filename
  }

  runtime {
    memory: "8 GB"
    docker: "quay.io/biocontainers/samtools:1.22.1--h96c455f_0"
  }
}

################################################################################
# task SortBam

task SortBam {
  input {
    File in_bam
    Int num_cpus = 16
  }

  String out_bam_filename = '~{basename(in_bam, ".bam")}.sorted.bam'

  command <<<
    /usr/bin/time -v \
      samtools sort -@ ~{num_cpus - 1} ~{in_bam} > ~{out_bam_filename}
  >>>

  output {
    File out_bam = out_bam_filename
  }

  runtime {
    cpu: num_cpus
    memory: "32 GB"
    docker: "quay.io/biocontainers/samtools:1.22.1--h96c455f_0"
  }
}

################################################################################
# task IndexBam

task IndexBam {
  input {
    File bam
  }

  String bam_bai_filename = '~{basename(bam)}.bai'

  command <<<
    /usr/bin/time -v \
      samtools index ~{bam} ~{bam_bai_filename}
  >>>

  output {
    File bam_bai = bam_bai_filename
  }

  runtime {
    memory: "8 GB"
    docker: "quay.io/biocontainers/samtools:1.22.1--h96c455f_0"
  }
}

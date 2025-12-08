version 1.0

task ExtractReferencePaths {
  input {
    File gbz
    String ref_name
  }

  command <<<
    /usr/bin/time -v \
      vg paths -x ~{gbz} -L -Q ~{ref_name} \
        > ref_path.lst
  >>>

  output {
    File ref_path = "ref_path.lst"
  }

  runtime {
    cpu: 1
    memory: "16 GB"
    docker: "quay.io/vgteam/vg:v1.68.0"
  }
}

#!/bin/bash

# Input files (paths should be provided as arguments or hardcoded)
sites_only_variant_filtered_vcf="$1"
hapmap_resource_vcf="$2"
omni_resource_vcf="$3"
one_thousand_genomes_resource_vcf="$4"
dbsnp_resource_vcf="$5"

# Optional machine_mem_mb (should be provided as an argument or hardcoded)
machine_mem_mb="$6"

# Calculate the total size in MiB (1 MiB = 1.048576 MB)
total_size_mb=$(du -csm "$sites_only_variant_filtered_vcf" \
                          "$hapmap_resource_vcf" \
                          "$omni_resource_vcf" \
                          "$one_thousand_genomes_resource_vcf" \
                          "$dbsnp_resource_vcf" | grep total | awk '{print $1}')
total_size_mib=$(echo "scale=6; $total_size_mb / 1.048576" | bc -l)

# Calculate auto_mem with ceil
auto_mem=$(echo "($total_size_mib * 2 + 0.999999)/1" | bc)

# Ensure auto_mem is treated as an integer
auto_mem=$(printf "%.0f" "$auto_mem")

# Determine machine_mem
if [ -z "$machine_mem_mb" ]; then
  if [ "$auto_mem" -lt 7000 ]; then
    machine_mem=7000
  else
    machine_mem=$auto_mem
  fi
else
  machine_mem=$machine_mem_mb
fi

# Calculate java_mem and max_heap
java_mem=$((machine_mem - 1000))
max_heap=$((machine_mem - 500))

# Output the results
echo "auto_mem: $auto_mem"
echo "machine_mem: $machine_mem"
echo "java_mem: $java_mem"
echo "max_heap: $max_heap"

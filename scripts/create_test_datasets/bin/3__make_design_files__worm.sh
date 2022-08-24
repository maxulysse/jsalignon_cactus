#!/bin/bash

specie="worm"
n_reads_atac=$1
n_reads_mrna=$2
run_config_file=$specie/conf/run.config
prepro_dir="preprocessing/${specie}"
source $get_test_datasets_bin_dir/get_test_datasets_functions.sh


# run.config
cat > ${specie}/conf/run.config <<EOL
params {
  specie            = 'worm'
  use_input_control = false
  save_bed_type     = 'all'
  chip_ontology     = 'all'
  chromatin_state   = 'iHMM.M1K16.worm_L3'
  threshold_type_for_splitting_subsets   = 'rank' 
  threshold_values_for_splitting_subsets = [ 200, 1000 ]
}
EOL

# atac_fastq.tsv and mrna_fastq.tsv
make_samples_info_file ${prepro_dir}
awk 'BEGIN {OFS = "\t"} { \
  sample_id = tolower($6) ; \
  gsub(/(rep|-|_control)/, "", sample_id); \
  gsub(/rluc/, "ctl", sample_id); \
  gsub(/ctrl/, "ctl", sample_id); \
  gsub(/sample_title_sample_title/, "sample_id", sample_id); \
  if (NR == 1) sample_id = "sample_id"; \
  print $1, $2, $3, $4, $5, $6, sample_id \
}' ${prepro_dir}/samplesheet/samples_info.tsv | column -t > ${prepro_dir}/samplesheet/samples_info_1.tsv
make_fastq_info_file $specie $n_reads_atac $n_reads_mrna
cp ${specie}/design/atac_fastq.tsv ${specie}/design/atac_fastq__with_input.tsv
grep -v input ${specie}/design/atac_fastq__with_input.tsv > ${specie}/design/atac_fastq__without_input.tsv

# comparisons.tsv
cat > ${specie}/design/comparisons.tsv <<EOL
hmg4 ctl
spt16 ctl
hmg4 spt16
EOL

# groups.tsv
cat > ${specie}/design/groups.tsv << EOL
all hmg4_vs_ctl spt16_vs_ctl hmg4_vs_spt16
ctl hmg4_vs_ctl spt16_vs_ctl
spt16 spt16_vs_ctl hmg4_vs_spt16
EOL

# regions_to_remove.tsv
cat > ${specie}/design/regions_to_remove.tsv << EOL
hmg4 Hmg4->chrIII:7,379,143-7,381,596
spt16 Spt16->chrI:10,789,130-10,793,152
EOL
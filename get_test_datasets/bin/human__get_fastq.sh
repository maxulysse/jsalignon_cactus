#!/bin/bash

specie="human"
prepro_dir="preprocessing/${specie}"
fastq_dir=${prepro_dir}/fastq
run_config_file=$specie/conf/run.config

source $get_test_datasets_bin_dir/get_test_datasets_functions.sh

# making directory structure
mkdir -p $specie/data/mrna $specie/data/atac $specie/conf $specie/design

# cleaning up the fastq folder
if [ -d $fastq_dir ]; then rm -r $fastq_dir ; fi

# downloading fastq files
nextflow run nf-core/fetchngs --input "$samples_ids_dir/srr_accession/srr_${specie}.txt" --outdir ${prepro_dir} -profile singularity -r 1.6 -resume -process.cache "deep"
# --force_sratools_download # => using this options results in files of the format "SRR7101009_R1.fastq.gz" instead of "SRX2794538_SRR5521297_R1.fastq.gz" which crash my parsing script

# checking sample details to rename them
make_samples_info_file ${prepro_dir}

# renaming files
rename -v 's/SRX/atac_SRX/' $fastq_dir/SRX2794*
rename -v 's/SRX/mrna_SRX/' $fastq_dir/SRX4029*
rename -v 's/_1.fastq.gz/_R1.fastq.gz/' $fastq_dir/*
rename -v 's/_2.fastq.gz/_R2.fastq.gz/' $fastq_dir/*
ls $fastq_dir

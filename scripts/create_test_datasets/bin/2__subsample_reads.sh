#!/bin/bash

specie=$1
n_reads_atac=$2
n_reads_mrna=$3

prepro_dir="preprocessing/${specie}"
source $create_test_datasets_bin_dir/create_test_datasets_functions.sh


# ATAC-Seq
nextflow $create_test_datasets_bin_dir/subsample_reads.nf --specie $specie --thousand_reads $n_reads_atac --experiment atac -resume

# mRNA-Seq
nextflow $create_test_datasets_bin_dir/subsample_reads.nf --specie $specie --thousand_reads $n_reads_mrna --experiment mrna -resume

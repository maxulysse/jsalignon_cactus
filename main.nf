#!/usr/bin/env nextflow

// shortening certain oftenly used parameters
out_dir = params.out_dir

// grouped = params.grouped
pub_mode = params.pub_mode

out_processed = "${out_dir}/Processed_Data"
out_fig_indiv = "${out_dir}/Figures_Individual"
// out_tab_indiv = "${out_dir}/Tables_Individual"


save_all_fastq  = params.save_fastq_type == 'all' ? true : false
save_all_bam    = params.save_bam_type   == 'all' ?  true : false
save_all_bed    = params.save_bed_type   == 'all' ?  true : false
save_last_fastq = params.save_fastq_type in ['last', 'all'] ?  true : false
save_last_bam   = params.save_bam_type   in ['last', 'all'] ?  true : false
save_last_bed   = params.save_bed_type   in ['last', 'all'] ?  true : false

do_atac = params.experiment_types in ['atac', 'both']
do_mRNA = params.experiment_types in ['mRNA', 'both']

// ATAC="/home/jersal/lluis/atac"
// cd $ATAC/experiment/test/2018-04-06/300K/
// nextflow run ${ATAC}/src/nextflow/pipeline_atac.nf -ansi-log false -dump-channels atac_kallisto




//////////////////////////////////////////////////////////////////////////////
//// DEFINING THE GENERAL DIRECTORY STRUCTURE

// Processed_Data Figures_Individual
// Processed_Data
//   1_Preprocessing/ATAC
//     1_reads
//       1_fastq
//         1_merged_reads
//         2_trimmed_reads
//       2_fastqc
//         1_raw_reads
//         2_trimmed_reads
//       3_bam
//         1_initial_alignment
//         2_filtering_unmapped_low_quality
//         3_filtering_duplicates
//         4_filtering_mitochondrial_reads
//         5_bamToBed_and_atac_shift
//         6_extended_bed
//       4_bigwig
//         1_raw
//         2_normalized
//       5_metrics
//         1_features_enrichment
//         2_library_complexity
//         3_alignment_op50_genome
//         4_intermediate_files
//         5_multiQC



//     2_peaks
//       1_raw
//       2_split
//       3_blacklist_removed
//       4_input_control_removed
//       5_annotated
//         1_individual
//         2_grouped
//       6_RNAi_regions_removed
//     3_DA
//       1_raw
//         DiffBind
//         gRange
//         bed
//       2_annotated
//         dataframe
//         ChIPseeker
//   2_Differential_Abundance/mRNA
//     1_fastqc
//     2_multiQC
//     3_mapping
//     4_DA
//   3_Enrichment
//     a_genes_sets
//     b_chrom_states
//     c_CHIP
//     d_motifs
//       1_homer_files
//       2_dataframe
//
//
// Figures_Individual
//   1_Preprocessing/ATAC
//     1_reads
//       Coverage
//       PCA_and_Correlations
//       Insert_Size
//       MultiQC
//     2_peaks
//       Saturation_Curve
//       Individual_Plots
//       Grouped_Plots
//     3_DA
//       Other_Plots
//       PCA
//       Volcano
//   2_Differential_Abundance/mRNA
//     1_multiQC
//     2_DA
//    3_Enrichment
//      1_DA_genes_self_overlap
//        a_venn_up_or_down
//        b_venn_up_and_down
//        c_matrix
//      1_Barplots: a_genes_sets, b_chrom_states, c_CHIP, d_motifs
//      3_Enrichment_heatmaps: a_genes_sets, b_chrom_states, c_CHIP, d_motifs
//
//
// Figures_Merged
//   1_Preprocessing
//   2_Differential_Abundance
//   3_Enrichment
//
// Tables_Individual
//   2_Differential_Abundance: ATAC_detailed, mRNA_detailed, res_filter, res_simple
//   3_Enrichment: func_anno(BP|CC|MF|KEGG), genes_self, peaks_self, CHIP, chrom_states, motifs 
//
// Tables_Merged



//////////////////////////////////////////////////////////////////////////////
//// ALL SECTIONS AND THE PROCESSES THEY CONTAIN


//// READS PROCESSING
// ATAC__merging_reads
// ATAC__trimming_adaptors
// ATAC__reads_fastqc_before_trimming
// ATAC__reads_fastqc_after_trimming
// ATAC__alignment_with_bowtie2
// ATAC__filtering_low_quality_reads
// ATAC__marking_duplicates
// ATAC__removing_duplicates
// ATAC__creation_of_raw_bigwig_tracks
// ATAC__correlation_between_raw_bigwig_tracks
// ATAC__removing_mitochondrial_reads
// ATAC__plot_insert_size_distribution
//
//// PEAKS CALLING
// ATAC__bamToBed_and_atacShift
// ATAC__extend_bed_before_peak_calling
// ATAC__saturation_curve
// ATAC__calling_peaks
// ATAC__splitting_sub_peaks
// ATAC__removing_blacklisted_regions
// ATAC__removing_input_control_peaks
//
//// READS METRICS
// ATAC__sampling_aligned_reads_for_statistics
// ATAC__reads_stat_1_features_enrichment
// ATAC__reads_stat_2_library_complexity
// ATAC__reads_stat_3_subsample_trimmed_reads
// ATAC__reads_stat_3_alignment_sampled_reads
// ATAC__statistics_on_aligned_reads
// ATAC__gathering_statistics_on_aligned_reads
// ATAC__splitting_statistics_for_multiqc
// ATAC__multiQC
//
//// PEAKS ANNOTATION AND VISUALISATION
// ATAC__annotating_individual_peaks
// ATAC__plotting_individual_peak_files
// ATAC__plotting_grouped_peak_files
// ATAC__removing_specific_regions
// ATAC__differential_abundance_analysis
// ATAC__annotating_all_peaks
//
//// MRNA SEQ
// mRNA__fastqc
// mRNA__MultiQC
// mRNA__mapping_with_kallisto
// mRNA__differential_abundance_analysis
//
//// PLOTTING DA RESULTS (VOLCANO, PCA)
// plotting_differential_gene_expression_results
// plotting_differential_accessibility_results
//
//// SAVING AND SPLITTING DIFFERENTIAL ABUNDANCE RESULTS
// mRNA__saving_detailed_results_tables
// ATAC__saving_detailed_results_tables
// splitting_differential_abundance_results_in_subsets
//
//// PLOTTING OVERLAP RESULTS
// plotting_venn_diagrams
// plotting_overlap_matrix
//
//// ENRICHMENT ANALYSIS
// compute_gene_set_ontologies_enrichments
// compute_peaks_self_overlap
// compute_pvalue_overlap_and_reformat_results
// compute_motif_overlap
// reformat_motifs_results
//
// PLOTTING ENRICHMENT RESULTS
// plot_enrichment_barplot
// plot_enrichment_heatmap
//
//// MERGING TABLES AND PDFs
// merge_tables
// merge_pdfs


//////////////////////////////////////////////////////////////////////////////
//// initializing channels

// tables
Counts_tables_Channel = Channel.empty()
Formatting_tables_Channel = Channel.empty()
// Merging_tables_Channel = Channel.empty()
Exporting_to_Excel_Channel = Channel.empty()

// pdfs
Merging_pdf_Channel = Channel.empty()


//////////////////////////////////////////////////////////////////////////////
//// creating mRNA-Seq channel


static def returnR2ifExists(r2files) {
  boolean exists = r2files[1].exists();
  boolean diff   = r2files[0] != r2files[1];
  if (exists & diff) { return(r2files)
  } else { return(r2files[0]) }
}

MRNA_reads_for_merging = Channel.create()
MRNA_reads_for_kallisto = Channel.create()

fastq_files = file("design/mrna_fastq.tsv")
Channel
  .from(fastq_files.readLines())
  .map{ it.split() }
  .map{ [ it[0], it[1..-1] ] }
  .transpose()
  .map{ [ it[0], file(it[1]), file(it[1].replace("_R1", "_R2") ) ] }
  .map{ [ it[0], returnR2ifExists(it[1, 2]) ] }
  .dump(tag:'mrna_fastq')
  .into{ MRNA_reads_for_fastqc ; MRNA_reads_for_kallisto }



//////////////////////////////////////////////////////////////////////////////
//// ATAC SEQ

//////////////////////////////////////////////////////////////////////////////
//// READS PROCESSING



ATAC_reads_for_merging = Channel.create()
ATAC_reads_for_trimming = Channel.create()

fastq_files = file("design/atac_fastq.tsv")
Channel
  .from(fastq_files.readLines())
  .map{ it.split() }
  .map{ [ it[0], it[1..-1] ] }
  .transpose()
  .map{ [ it[0], file(it[1]), file(it[1].replace("_R1", "_R2")) ] }
  .tap{ ATAC_reads_for_fastqc }
  .map{ [ it[0], [ it[1], it[2] ] ] }
  .transpose()
  .groupTuple()
  .dump(tag:'atac_fastq') {"ATAC peaks for fastqc: ${it}"}
  .choice(ATAC_reads_for_trimming, ATAC_reads_for_merging) { it[1].size() == 2 ? 0 : 1 }

ATAC_reads_for_merging
  .dump(tag:'atac_merging') {"ATAC peaks for merging: ${it}"}
  .set{ ATAC_reads_for_merging1 }





process ATAC__merging_reads {
  tag "${id}"

  container = params.fastqc


  when: do_atac

  // publishDir path: "${out_processed}/1_Preprocessing/ATAC/1_reads/1_fastq/1_merged_reads", mode: "${pub_mode}", enabled: save_all_fastq
  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__fastq_merged", mode: "${pub_mode}", enabled: save_all_fastq

  input:
    set id, file(files_R1_R2) from ATAC_reads_for_merging1

  output:
    set id, file('*R1_merged.fastq.gz'), file('*R2_merged.fastq.gz') into ATAC_reads_for_trimming1

  script:
  """
      cat `ls *R1* | sort` > ${id}_R1_merged.fastq.gz
      cat `ls *R2* | sort` > ${id}_R2_merged.fastq.gz
  """

}


ATAC_reads_for_trimming
  .map{ it.flatten() }
  .mix( ATAC_reads_for_trimming1 )
  .dump(tag:'atac_trimming') {"ATAC peaks for trimming: ${it}"}
  .set { ATAC_reads_for_trimming2 }



process ATAC__trimming_adaptors {
  tag "${id}"

  container = params.skewer_pigz

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__fastq_trimmed", mode: "${pub_mode}", enabled: save_last_fastq

  when: do_atac

  input:
    set id, file(read1), file(read2) from ATAC_reads_for_trimming2

  output:
    set id, file("*R1*_trim.fastq.gz"), file("*R2*_trim.fastq.gz") into Trimmed_ATAC_reads_for_fastqc, Trimmed_reads_for_alignment, Trimmed_reads_for_subsampling
    file("*.log")

  shell:

  '''

      R1=!{read1}
      R2=!{read2}
      id=!{id}
      Nb_of_threads=!{params.nb_threads}
      
      R1TRIM=$(basename ${R1} .fastq.gz)_trim.fastq
      R2TRIM=$(basename ${R2} .fastq.gz)_trim.fastq
      
      skewer --quiet -x CTGTCTCTTATA -y CTGTCTCTTATA -m pe ${R1} ${R2} -o !{id} > trimer_verbose.txt
      mv !{id}-trimmed.log ${id}_skewer_trimming.log
      mv !{id}-trimmed-pair1.fastq $R1TRIM
      mv !{id}-trimmed-pair2.fastq $R2TRIM
      pigz -p ${Nb_of_threads} $R1TRIM
      pigz -p ${Nb_of_threads} $R2TRIM
      
      pigz -l $R1TRIM.gz > !{id}_pigz_compression.log
      pigz -l $R2TRIM.gz >> !{id}_pigz_compression.log
      
  '''
}

// this line crashed the script somehow. I don't really get the grep fast here anyway so I changed it
// pigz -l $R2TRIM.gz | grep fastq - >> !{id}_pigz_compression.log

// cp $R1 $R1TRIM.gz
// cp $R2 $R2TRIM.gz
// touch tmp.log

// R1TRIM=$(basename ${R1} .fastq.gz)_trim.fastq
// R2TRIM=$(basename ${R2} .fastq.gz)_trim.fastq
// 

// skewer potentially useful options
// -m, --mode <str> trimming mode; 1) single-end -- head: 5' end; tail: 3' end; any: anywhere
//                                 2) paired-end -- pe: paired-end; mp: mate-pair; ap: amplicon (pe)
// -q, --end-quality  <int> Trim 3' end until specified or higher quality reached; (0). => Maybe one could later set -q 20. But on "https://informatics.fas.harvard.edu/atac-seq-guidelines.html" they say: "Other than adapter removal, we do not recommend any trimming of the reads. Such adjustments can complicate later steps, such as the identification of PCR duplicates."
// -t, --threads <int>   Number of concurrent threads [1, 32]; (1)
// -A, --masked-output  Write output file(s) for trimmed reads (trimmed bases converted to lower case) (no)

// pigz potentially useful options
// -k, --keep           Do not delete original file after processing
// -0 to -9, -11        Compression level (level 11, zopfli, is much slower) => the default is 6
// --fast, --best       Compression levels 1 and 9 respectively
// -p, --processes n    Allow up to n compression threads (default is the number of online processors, or 8 if unknown)
// -c, --stdout         Write all processed output to stdout (won't delete)
// -l, --list           List the contents of the compressed input



process ATAC__reads_fastqc_before_trimming {
  tag "${id}"

  container = params.fastqc

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__fastqc_raw", mode: "${pub_mode}"

  when: do_atac

  input:
    set id, file(read1), file(read2) from ATAC_reads_for_fastqc

  output:
    file("*.{zip, html}") into FastQC_reports_before_trimming_for_multiQC

  script:
  """

  fastqc -t 2 ${read1} ${read2}

  """

}



process ATAC__reads_fastqc_after_trimming {
  tag "${id}"

  container = params.fastqc

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__fastqc_trimmed", mode: "${pub_mode}"

  when: do_atac

  input:
    set id, file(read1), file(read2) from Trimmed_ATAC_reads_for_fastqc

  output:
    file("*.{zip, html}") into FastQC_reports_after_trimming_for_multiQC

  script:
  """

    fastqc -t 2 ${read1} ${read2}

  """
}


process ATAC__alignment_with_bowtie2 {
  tag "${id}"

  container = params.bowtie2_samtools

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__bam", mode: "${pub_mode}", enabled: save_all_bam

  when: do_atac

  input:
    set id, file(read1), file(read2) from Trimmed_reads_for_alignment

  output:
    set id, file("*.bam") into Bam_for_filtering_LQ_reads, Bam_for_sampling
    file("*.txt")
    file("*.qc")

  script:
  """
    bowtie2 -p ${params.nb_threads} \
      --very-sensitive \
      --end-to-end \
      --no-mixed \
      -X 2000 \
      --met 1 \
      --met-file "${id}_bowtie2_align_metrics.txt" \
      -x "${params.bowtie2_indexes}" \
      -q -1 "${read1}" -2 "${read2}" \
      | samtools view -bS -o "${id}.bam" -

      samtools flagstat "${id}.bam" > "${id}_flagstat.qc"

  """
}


// this process filter bad quality reads: unmapped, mate unmapped, no primary alignment, low MAPQ

process ATAC__filtering_low_quality_reads {
  tag "${id}"

  container = params.bowtie2_samtools

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__bam_no_lowQ", mode: "${pub_mode}", enabled: save_all_bam

  when: do_atac

  input:
    set id, file(bam) from Bam_for_filtering_LQ_reads

  output:
    set id, file("*_filter_LQ.bam") into Bam_for_marking_duplicates
    file("*_flagstat.qc")

  script:
  """

  samtools view -F 1804 \
                -b \
                -q "${params.sam_MAPQ_threshold}" \
                ${bam} | \
  samtools sort - -o "${id}_filter_LQ.bam"

  samtools flagstat "${id}_filter_LQ.bam" > "${id}_flagstat.qc"

  """
}


process ATAC__marking_duplicates {
  tag "${id}"

  container = params.picard

  // publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__bam_no_lowQ_dupli", mode: "${pub_mode}", enabled: save_all_bam

  when: do_atac

  input:
    set id, file(bam) from Bam_for_marking_duplicates

  output:
    set id, file("*_dup_marked.bam") into Bam_for_removing_duplicates
    file("*_dup.qc")

  script:
  """

    picard -Xmx20G MarkDuplicates \
      -INPUT "${bam}" \
      -OUTPUT "${id}_dup_marked.bam" \
      -METRICS_FILE "${id}_dup.qc" \
      -VALIDATION_STRINGENCY LENIENT \
      -ASSUME_SORTED true \
      -REMOVE_DUPLICATES false \
      -TMP_DIR "."


  """
}


// this process remove duplicates, index bam files and generates final stat file

process ATAC__removing_duplicates {
  tag "${id}"

  container = params.bowtie2_samtools

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__bam_no_lowQ_dupli", mode: "${pub_mode}", enabled: save_all_bam

  when: do_atac

  input:
    set id, file(bam) from Bam_for_removing_duplicates

  output:
    set id, file("*.bam"), file("*.bai") into Bam_for_raw_bigwig, Bam_for_removing_mitochondrial_reads
    file("*_flagstat.qc")

  script:
  """

    samtools view -F 1804 "${bam}" -b -o "${id}_dup_rem.bam"
    samtools index -b "${id}_dup_rem.bam"
    samtools flagstat "${id}_dup_rem.bam" > "${id}_flagstat.qc"

  """
}


process ATAC__creation_of_raw_bigwig_tracks {
  tag "${id}"

  container = params.deeptools

  publishDir path: "${out_dir}", mode: "${pub_mode}", saveAs: {
    if (it.indexOf(".pdf") > 0) "Figures_Individual/1_Preprocessing/ATAC__reads__coverage/${it}"
    else if (it.indexOf("_raw.bw") > 0) "Processed_Data/1_Preprocessing/ATAC__reads__bigwig_raw/${it}"
    else if (it.indexOf("_RPGC_norm.bw") > 0) "Processed_Data/1_Preprocessing/ATAC__reads__bigwig_norm/${it}"
  }

  when: do_atac & params.do_bigwig

  input:
    set id, file(bam), file(bai) from Bam_for_raw_bigwig

  output:
    set val("ATAC__reads__coverage"), val('1_Preprocessing'), file("*.pdf") into ATAC_reads_coverage_for_merging_pdfs
    file("*_raw.bw")
    file("*_RPGC_norm.bw") into Bigwig_for_correlation optional true

  script:
  """

      bamCoverage --bam ${bam} --outFileName ${id}_raw.bw --binSize ${params.binsize_bigwig_creation} --numberOfProcessors ${params.nb_threads} --blackListFileName ${params.blacklisted_regions} --effectiveGenomeSize ${params.effective_genome_size}

      plotCoverage --bam ${bam} --blackListFileName ${params.blacklisted_regions} --numberOfProcessors ${params.nb_threads} --numberOfSamples ${params.nb_1bp_site_to_sample_for_coverage} --plotTitle ${id}_coverage --plotFile ${id}_coverage.pdf

  """
}

Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_reads_coverage_for_merging_pdfs.groupTuple(by: [0, 1]))


// bamCoverage --bam ${bam} --outFileName ${id}_RPGC_norm.bw --binSize ${params.binsize_bigwig_creation}  --numberOfProcessors ${params.nb_threads} --blackListFileName ${params.blacklisted_regions} --normalizeUsing RPGC --effectiveGenomeSize ${params.effective_genome_size}

// plotCoverage --bam ${bam} --blackListFileName ${params.blacklisted_regions} --numberOfProcessors ${params.nb_threads} --numberOfSamples ${params.nb_1bp_site_to_sample_for_coverage} --plotTitle ${id}_coverage --plotFile ${id}_coverage.pdf


// """
//     plotBamCoverage.sh ${bam} ${id} ${params.binsize_bigwig_creation} ${params.nb_threads} ${params.blacklisted_regions} ${params.effective_genome_size} ${params.nb_1bp_site_to_sample_for_coverage}
// 
// """



Bigwig_for_correlation
    .collect()
    .into{ bw_with_input_control; bw_without_input_control }

bw_without_input_control
    .flatten()
    .filter{ !(it =~ /input/) }
    .collect()
    .map{ [ 'without_control', it ] }
    .set{ bw_without_input_control1 }

bw_with_input_control
    .map{ [ 'with_control', it ] }
    .concat(bw_without_input_control1)
    .dump(tag:'bigwigs') {"bigwigs for cor and PCA: ${it}"}
    .set{ Bigwig_for_correlation1 }


process ATAC__correlation_between_raw_bigwig_tracks {

  tag "${input_control_present}"

  container = params.deeptools

  publishDir path: "${out_fig_indiv}/${out_path}", mode: "${pub_mode}", saveAs: { 
         if (it.indexOf("_pca.pdf") > 0) "ATAC__reads__PCA/${it}" 
    else if (it.indexOf("_cor.pdf") > 0) "ATAC__reads__correlations/${it}" 
  }

  when: do_atac

  input:
    val out_path from Channel.value('1_Preprocessing') 
    set input_control_present, file("*") from Bigwig_for_correlation1

  output:
    file("*.npz")
    set val("ATAC__reads__PCA"),          out_path, file("*_pca.pdf") into ATAC_Reads_PCA_for_merging_pdfs
    set val("ATAC__reads__correlations"), out_path, file("*_cor.pdf") into ATAC_Reads_Correl_for_merging_pdfs

  script:
  """


    plotPCAandCorMat.sh ${input_control_present} ${params.blacklisted_regions} ${params.binsize_bigwig_correlation}


  """
}

Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_Reads_PCA_for_merging_pdfs.groupTuple(by: [0, 1]))
Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_Reads_Correl_for_merging_pdfs.groupTuple(by: [0, 1]))




process ATAC__removing_reads_in_mitochondria_and_contigs {
  tag "${id}"

  container = params.bowtie2_samtools

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__bam_no_lowQ_dupli_mito", mode: "${pub_mode}", enabled: save_last_bam

  when: do_atac

  input:
    set id, file(bam), file(bai) from Bam_for_removing_mitochondrial_reads

  output:
    set id, file("*.bam") into Bam_for_plotting_inserts_distribution, Bam_for_atac_shifting
    file "*_reads_per_chrm_before_removal.txt"
    file "*_reads_per_chrm_after_removal.txt"

  shell:
    '''
      id=!{id}
      bam=!{bam}
      chromosomes_sizes=!{params.chromosomes_sizes}

      samtools view ${bam} | awk ' $1 !~ /@/ {print $3}' - | uniq -c > "${id}_reads_per_chrm_before_removal.txt"

      regions_to_keep=$(cut -f1 $chromosomes_sizes | paste -sd " ")

      samtools view -Sb ${bam} $regions_to_keep | tee ${id}_no_mito.bam | samtools view - | awk '{print $3}' OFS='\t' | uniq -c > "${id}_reads_per_chrm_after_removal.txt"
      
      
    '''

}



// samtools view -b ${bam} I II III IV V X | tee ${id}_no_mito.bam | samtools view - | awk ' \$1 !~ /@/ {print \$3}' - | uniq -c > "${id}_reads_per_chrm_after_removal.txt"

// chromosomes_sizes=~/workspace/cactus/data/fly/genome/annotation/filtered/chromosomes_sizes.txt

// cut -f1 $chromosomes_sizes

// samtools view  ${bam} $regions_to_keep | awk '{print $3}' OFS='\t' - | sort | uniq -c
// samtools view  ${bam} | awk '{print $3}' OFS='\t' - | sort | uniq -c

// samtools view  hmg4_2_no_mito.bam | awk '{print $3}' OFS='\t' - | sort | uniq -c
// samtools view  hmg4_2_no_mito.bam | head



process ATAC__plot_insert_size_distribution {
  tag "${id}"

  container = params.picard

  publishDir path: "${out_fig_indiv}/${out_path}/ATAC__reads__insert_size", mode: "${pub_mode}"

  when: do_atac

  input:
    val out_path from Channel.value('1_Preprocessing') 
    set id, file(bam) from Bam_for_plotting_inserts_distribution

  output:
    set val("ATAC__reads__insert_size"), out_path, file("*.pdf") into ATAC_Reads_InsertSize_for_merging_pdfs

  script:
  """

    picard -Xmx${params.workMem} CollectInsertSizeMetrics \
      -INPUT "${bam}" \
      -OUTPUT "${id}.insertSizes.txt" \
      -METRIC_ACCUMULATION_LEVEL ALL_READS \
      -Histogram_FILE "${id}.insertSizes.pdf" \
      -TMP_DIR .


  """
}

Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_Reads_InsertSize_for_merging_pdfs.groupTuple(by: [0, 1]))





//////////////////////////////////////////////////////////////////////////////
//// PEAKS CALLING


// this process converts the bam to bed, adjusts for the shift of the transposase (atac seq) and keeps only a bed format compatible with macs2

process ATAC__bamToBed_and_atacShift {
  tag "${id}"

  container = params.samtools_bedtools_perl

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__bam_asBed_atacShift", mode: "${pub_mode}", enabled: save_all_bam, saveAs: { if (it.indexOf(".bam") > 0) "$it" }

  when: do_atac

  input:
    set id, file(bam) from Bam_for_atac_shifting

  output:
    set id, file("*.bed") into Bed_for_extending_before_macs2
    set id, file("*.bam*") into Reads_for_diffbind

  script:
  """

    bamToBed_and_atacShift.sh ${bam} ${id} ${params.chromosomes_sizes}

  """
}


// Example of a read pair:

// input:
// samtools view n301b170_2_no_mito.bam | grep SRR11607686.9081238 - | cut -f1-9
//       QNAME             FLAG           RNAME    POS    MAPQ    CIGAR  RNEXT    PNEXT   TLEN
// SRR11607686.9081238     163     211000022278033 357     31      37M     =       408     88
// SRR11607686.9081238     83      211000022278033 408     31      37M     =       357     -88

// output:
// grep "SRR11607686.9081238/2\|SRR11607686.9081238/1" n301b170_2_1bp_shifted_reads.bed
// 211000022278033 360     361     SRR11607686.9081238/2   88      +
// 211000022278033 438     439     SRR11607686.9081238/1   -88     -

// reads on the + strand are shifted by + 4 base pair -1 (different coordinate system) (357 + 4 -1 = 360)
// reads on the - strand are shifted by - 5 base pair -1 (different coordinate system) (445 -5 - 1 = 439)

// explanations for the input:
// the fragment has a size of 88 bp from 
// ranges: 
// - read 1 [357-394 -> size: 37]
// - read 2 [408-445 -> size: 37]
// - insert [357-445 -> size: 88]
// - fragment [345-457 -> size: 112] (not entirely sure for this. I just added 12 for the ATAC-Seq adapter length)
// https://www.frontiersin.org/files/Articles/77572/fgene-05-00005-HTML/image_m/fgene-05-00005-g001.jpg
// https://samtools-help.narkive.com/BpGYAdaT/isize-field-determining-insert-sizes-in-paired-end-data

// Note: here the 1 base pair long (5') transposase-shifted peaks are sent to DiffBind directly for Differential Accessibility Analysis.
// However, for macs2, they are previously extended by 75 bp (Alternatively, this shift could be done in macs with this option: --shift -75 in macs2)



process ATAC__extend_bed_before_peak_calling {
  tag "${id}"

  container = params.samtools_bedtools_perl

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__reads__bam_asBed_atacShift_extendedBed", mode: "${pub_mode}", enabled: save_last_bam

  when: do_atac

  input:
    set id, file(bed) from Bed_for_extending_before_macs2

  output:
    set id, file("*.bed") into Reads_bed_format_for_bam_stats, Reads_bed_format_for_peak_calling, Reads_bed_format_for_saturation_curve

  script:
  """

      slopBed -i ${bed} -g "${params.chromosomes_sizes}" -l 75 -r -75 -s > "${id}_for_macs.bed"

  """

}

// Example of a read pair:

// input:
// grep "SRR11607686.9081238/2\|SRR11607686.9081238/1" n301b170_2_1bp_shifted_reads.bed
// 211000022278033 360     361     SRR11607686.9081238/2   88      +
// 211000022278033 438     439     SRR11607686.9081238/1   -88     -

// output:
// grep "SRR11607686.9081238/2\|SRR11607686.9081238/1" n301b170_2_for_macs.bed
// 211000022278033 285     286     SRR11607686.9081238/2   88      +
// 211000022278033 513     514     SRR11607686.9081238/1   -88     -

// reads are extended in opposite directions: -75bp on the + strand and +75 bp on the - strand
// 360 - 75 = 285
// 439 + 75 = 514


process ATAC__saturation_curve {
  tag "${id}"

  container = params.macs2

  publishDir path: "${out_fig_indiv}/${out_path}/ATAC__peaks__saturation_curve", mode: "${pub_mode}"

  when: do_atac

  input:
    val out_path from Channel.value('1_Preprocessing') 
    set id, file(bed) from Reads_bed_format_for_saturation_curve

  output:
    set val("ATAC__peaks__saturation_curve"), out_path, file('*.pdf') into ATAC_Saturation_Curve_for_merging_pdfs

  when: params.do_saturation_curve

  script:
  """

      export TMPDIR="." PYTHON_EGG_CACHE="."

      PERCENTS=`seq 10 10 100`

      for PERCENT in \${PERCENTS}
      do
        BED_FILE="${id}_sampled_\${PERCENT}_percent.bed"

        macs2 randsample -i ${bed} \
          --seed 38 \
          -o \${BED_FILE} \
          --percentage \${PERCENT} \
          -f BED

        macs2 callpeak -t \${BED_FILE} \
          -f BED \
          --name \${BED_FILE}_macs2 \
          --gsize "${params.macs2_mappable_genome_size}" \
          --qvalue "${params.macs2_qvalue}" \
          --nomodel \
          --extsize 150 \
          -B \
          --keep-dup all \
          --call-summits
      done

      Rscript "${projectDir}/bin/plot_saturation_curve.R"

  """
}

Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_Saturation_Curve_for_merging_pdfs.groupTuple(by: [0, 1]))



process ATAC__calling_peaks {
  tag "${id}"

  container = params.macs2

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__peaks__raw", mode: "${pub_mode}", enabled: save_all_bed

  when: do_atac

  input:
    set id, file(bed) from Reads_bed_format_for_peak_calling

  output:
    set id, file("*.narrowPeak") into Peaks_for_sub_peaks_calling

  script:
  """

    export TMPDIR="." PYTHON_EGG_CACHE="."

    macs2 callpeak  \
        -t "${bed}" \
        -f BED \
        -n "${id}_macs2" \
        -g "${params.macs2_mappable_genome_size}" \
        -q "${params.macs2_qvalue}" \
        --nomodel \
        --extsize 150 \
        -B \
        --keep-dup all \
        --call-summits

  """
}

//// some relevant links 
// https://github.com/macs3-project/MACS/issues/145
// https://twitter.com/XiChenUoM/status/1336658454866325506
// https://groups.google.com/g/macs-announcement/c/4OCE59gkpKY/m/v9Tnh9jWriUJ
// https://www.biostars.org/p/209592/
// https://hbctraining.github.io/In-depth-NGS-Data-Analysis-Course/sessionV/lessons/04_peak_calling_macs.html
// https://hbctraining.github.io/Intro-to-ChIPseq/lessons/05_peak_calling_macs.html

//// Here are details for the macs2 parameters (the macs2 website is broken)
// https://www.biostars.org/p/207318/
// --extsize
//     While '--nomodel' is set, MACS uses this parameter to extend reads in 5'->3' direction to fix-sized fragments. For example, if the size of binding region for your transcription factor is 200 bp, and you want to bypass the model building by MACS, this parameter can be set as 200. This option is only valid when --nomodel is set or when MACS fails to build model and --fix-bimodal is on.
// 
// --shift
//     Note, this is NOT the legacy --shiftsize option which is replaced by --extsize! You can set an arbitrary shift in bp here. Please Use discretion while setting it other than default value (0). When --nomodel is set, MACS will use this value to move cutting ends (5') then apply --extsize from 5' to 3' direction to extend them to fragments. When this value is negative, ends will be moved toward 3'->5' direction, otherwise 5'->3' direction. Recommended to keep it as default 0 for ChIP-Seq datasets, or -1 * half of EXTSIZE together with --extsize option for detecting enriched cutting loci such as certain DNAseI-Seq datasets. Note, you can't set values other than 0 if format is BAMPE or BEDPE for paired-end data. Default is 0.

//// a recommanded setting to use both read pairs is the following:
// https://github.com/macs3-project/MACS/issues/145#issuecomment-742593158
// https://twitter.com/XiChenUoM/status/1336658454866325506
// macs2 callpeak -f BED --shift -100 --extsize 200 ...


// In my analysis I shift the reads manually by 75 bp with slopBed (process ATAC__extend_bed_before_peak_calling). So I don't need to use the shift argument in the call to macs2

//// There is also a justification to use 150 bp instead of 200:
// https://twitter.com/hoondy/status/1337170830997004290
// Is there any reason you chose the size as 200bp? For example, I use "shift -75 --extsize 150" (approx. size of nucleosome) and wonder if there were any benefit of making the unit of pileup 200bp.
// We use 200 due to habit. The choice is arbitrary. Not sure how diff it makes. Intuitively smaller fragLen give better res. but it can’t be too short. Check Fig1 in this ref (not ATAC though) https://ncbi.nlm.nih.gov/pmc/articles/PMC2596141/ 75 gives better res. Maybe that’s the reason ENCODE use it.

//// So to sum up: 
// - the two ends of each read pair are analyzed separately
// - we keep only the 5' end of each read pair. This is were we want our peak to be centered
// - we shift the reads to take into account the transposase (+4 bp on + strand, -5 on the - strand)
// - we shift the reads manually by -75 bp (in the 5' direction)
// - we use macs2 with the argument --extsize 150 which indicate to extend the read by 150 bp in the 3' direction. This way they will be centered in the original 5' location. 150 bp is the approximate size of nucleosome.
// - the peaks in the .narrowPeak file are 150 base pair long


process ATAC__splitting_sub_peaks {
  tag "${id}"

  container = params.samtools_bedtools_perl

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__peaks__split", mode: "${pub_mode}", enabled: save_all_bed

  when: do_atac

  input:
    set id, file(peaks) from Peaks_for_sub_peaks_calling

  output:
    set id, file("*_split_peaks.narrowPeak") into Peaks_for_blacklist_removal

  script:
  """

      perl "${projectDir}/bin/splitMACS2SubPeaks.pl" "${peaks}" > "${id}_split_peaks.narrowPeak"

  """
}



process ATAC__removing_blacklisted_regions {
  tag "${id}"

  container = params.samtools_bedtools_perl

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__peaks__split__no_BL", mode: "${pub_mode}", enabled: save_all_bed

  when: do_atac

  input:
    set id, file(peaks) from Peaks_for_blacklist_removal

  output:
    file("*.bed")
    set id, file("*_peaks_kept_after_blacklist_removal.bed") into Peaks_wo_blacklist
    set id, file("*_peaks_kept_after_blacklist_removal.bed") into Raw_peaks_for_annotations_in_R


  script:
  """

      intersectBed -v -a "${peaks}" -b "${params.blacklisted_regions}" > "${id}_peaks_kept_after_blacklist_removal.bed"

      intersectBed -u -a "${peaks}" -b "${params.blacklisted_regions}" > "${id}_peaks_lost_after_blacklist_removal.bed"


  """

}

// there are two output channels because:
// all peaks including input control are sent for annotation by ChipSeeker to get the distribution of peaks in various genomic locations
// the peaks are then sent for input control removal before DiffBind analysis

    // cat "${id}_peaks_kept_after_blacklist_removal.bed" | awk -F'\t' 'BEGIN {OFS = FS} { if ( \$1 == "MtDNA" ) { \$1 = "chrM" } else { \$1 = "chr"\$1 };  print \$0 }' > "${id}_peaks_kept_after_blacklist_removal_2.bed"

// println "params.use_input_control: ${params.use_input_control}"

Peaks_wo_blacklist
  .branch {
    w_input_control: params.use_input_control
    wo_input_control: true
  }
  .set { Peaks_wo_blacklist_1 }

// this command redirects the channel items to: 
// Peaks_wo_blacklist_1.w_input_control  if params.use_input_control = true
// Peaks_wo_blacklist_1.wo_input_control if params.use_input_control = false


Peaks_wo_blacklist_1.w_input_control
  // .view{"test_IP: ${it}"}
  .branch { it ->
    peaks_control: it[0] == 'input'
    peaks_treatment: true
  }
  .set { Peaks_wo_blacklist_2 }


Peaks_wo_blacklist_2.peaks_treatment
    .combine(Peaks_wo_blacklist_2.peaks_control)
    .map { it[0, 1, 3] }
    .dump(tag:'peaks_input_control') {"Peaks with input_control controls: ${it}"}
    .set { Peaks_treatment_with_control }


process ATAC__removing_input_control_peaks {
  tag "${id}"

  container = params.samtools_bedtools_perl

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__peaks__split__no_BL_input_control", mode: "${pub_mode}", enabled: save_all_bed

  when: do_atac

  input:
    set id, file(peaks), file(input_control_peaks) from Peaks_treatment_with_control

  output:
    file("*.bed")
    set id, file("*_peaks_kept_after_input_control_removal.bed") into Peaks_for_removing_specific_regions

  script:
  """

      input_control_overlap_portion="0.2"

      intersectBed -wa -v -f \${input_control_overlap_portion} -a "${peaks}" -b "${input_control_peaks}" > "${id}_peaks_kept_after_input_control_removal.bed"

      intersectBed -wa -u -f \${input_control_overlap_portion} -a "${peaks}" -b "${input_control_peaks}" > "${id}_peaks_lost_after_input_control_removal.bed"

  """
}

Peaks_for_removing_specific_regions_1 = 
  Peaks_wo_blacklist_1.wo_input_control
  .concat(Peaks_for_removing_specific_regions)



//////////////////////////////////////////////////////////////////////////////
//// READS STATISTICS

process ATAC__sampling_aligned_reads_for_statistics {
  tag "${id}"

  container = params.samtools_bedtools_perl

  when: do_atac

  input:
    set id, file(bam) from Bam_for_sampling

  output:
    set id, file("*.sam") into Bam_for_stats_library_complexity
    set id, file("*_sorted.bam"), file("*.bai") into Bam_for_stats_features_enrichment, Bam_for_stats_mito_percent
    set id, file("*.NB_ALIGNED_PAIRS*"), file("*.RAW_PAIRS*") into Nb_aligned_pairs_for_stats

  script:
  """

    # keeping only mapped alignment (flag 0x4) that are not secondary (flag 0x100, multimappers) or supplementary (flag 0x800, chimeric entries) alignments
    samtools view -F 0x904 -H ${bam} > ${id}_sampled.sam

    # sampling a certain number of reads
    samtools view -F 0x904 ${bam} | shuf - -n ${params.nb_sampled_reads} >> ${id}_sampled.sam

    # conversion to bam, sorting and indexing of sampled reads
    samtools view -Sb -o ${id}_sampled.bam ${id}_sampled.sam
    samtools sort -o ${id}_sorted.bam ${id}_sampled.bam
    samtools index ${id}_sorted.bam

    NB_ALIGNED_PAIRS=`samtools view -F 0x4 ${bam} | cut -f 1 | sort -T . | uniq | wc -l`
    RAW_PAIRS=`samtools view ${bam}| cut -f 1 | sort -T . | uniq | wc -l`

    touch \$NB_ALIGNED_PAIRS.NB_ALIGNED_PAIRS_${id}
    touch \$RAW_PAIRS.RAW_PAIRS_${id}

  """

}


// this process prepares ATAC-Seq related statistics on aligned reads

process ATAC__reads_stat_1_features_enrichment {
  tag "${id}"

  container = params.samtools_bedtools_perl

  // publishDir path: "${out_processed}/1_Preprocessing/ATAC/1_reads/5_metrics/1_features_enrichment", mode: "${pub_mode}"

  when: do_atac

  input:
  set id, file(bam), file(bai) from Bam_for_stats_features_enrichment

  output:
  set id, file("*_reads_features_enrichment.txt") into Features_enrichment_for_statistics

  shell:
  '''
    
    id=!{id}
    bam=!{bam}
    BED_PATH=!{params.bed_regions}
  
    getTotalReadsMappedToBedFile () { bedtools coverage -a $1 -b $2 | cut -f 4 | awk '{ sum+=$1} END {print sum}' ;}
    
    

    PROMOTER=`getTotalReadsMappedToBedFile $BED_PATH/promoters.bed ${bam}`
    EXONS=`getTotalReadsMappedToBedFile $BED_PATH/exons.bed ${bam}`
    INTRONS=`getTotalReadsMappedToBedFile $BED_PATH/introns.bed ${bam}`
    INTERGENIC=`getTotalReadsMappedToBedFile $BED_PATH/intergenic.bed ${bam}`
    GENES=`getTotalReadsMappedToBedFile $BED_PATH/genes.bed ${bam}`
    BAM_NB_READS=`samtools view -c ${bam}`

    echo "PROMOTER EXONS INTRONS INTERGENIC GENES BAM_NB_READS" > ${id}_reads_features_enrichment.txt
    echo "$PROMOTER $EXONS $INTRONS $INTERGENIC $GENES $BAM_NB_READS" >> ${id}_reads_features_enrichment.txt

    awkDecimalDivision () { awk -v x=$1 -v y=$2 'BEGIN {printf "%.2f\\n", 100 * x / y }' ; }

    P_PROM=$(awkDecimalDivision $PROMOTER $BAM_NB_READS)
    P_EXONS=$(awkDecimalDivision $EXONS $BAM_NB_READS)
    P_INTRONS=$(awkDecimalDivision $INTRONS $BAM_NB_READS)
    P_INTERGENIC=$(awkDecimalDivision $INTERGENIC $BAM_NB_READS)
    P_GENES=$(awkDecimalDivision $GENES $BAM_NB_READS)
    P_READS=$(awkDecimalDivision $BAM_NB_READS $BAM_NB_READS)

    echo "$P_PROM $P_EXONS $P_INTRONS $P_INTERGENIC $P_GENES $P_READS" >> ${id}_reads_features_enrichment.txt

  '''

}

// bedtools_coverage_only () { bedtools coverage -a $1 -b $2 ;}
// bedtools_coverage_only $BED_PATH/promoters.bed ${bam} | head
// bedtools_coverage_only $BED_PATH/promoters.bed ${bam} | cut -f 4 | head



process ATAC__reads_stat_2_library_complexity {
  tag "${id}"

  container = params.picard

  // publishDir path: "${out_processed}/1_Preprocessing/ATAC/1_reads/5_metrics/2_library_complexity", mode: "${pub_mode}"

  when: do_atac

  input:
  set id, file(sam) from Bam_for_stats_library_complexity

  output:
  set id, file("*_library_complexity.txt") into Library_complexity_for_statistics

  script:
  """

    picard -Xmx${params.workMem} \
    EstimateLibraryComplexity \
    -INPUT ${sam} \
    -OUTPUT ${id}_library_complexity.txt

  """

}


// this process samples reads from fastq files

process ATAC__reads_stat_3_subsample_trimmed_reads {
  tag "${id}"

  container = params.bbmap

  // publishDir path: "${out_processed}/1_Preprocessing/ATAC/1_reads/5_metrics/3_alignment_op50_genome", mode: "${pub_mode}"

  when: do_atac

  input:
    set id, file(read1), file(read2) from Trimmed_reads_for_subsampling

  output:
    set id, file("*R1.fastq"), file("*R2.fastq") into Sampled_reads_for_alignment

  script:
  """

    reformat.sh in1=${read1} in2=${read2} out1=${id}_subsampled_R1.fastq out2=${id}_subsampled_R2.fastq samplereadstarget=${params.nb_sampled_reads}

  """
}


process ATAC__reads_stat_3_alignment_sampled_reads {
  tag "${id}"

  container = params.bowtie2_samtools

  // publishDir path: "${out_processed}/1_Preprocessing/ATAC/1_reads/5_metrics/3_alignment_op50_genome", mode: "${pub_mode}"

  when: do_atac

  input:
    set id, file(read1), file(read2) from Sampled_reads_for_alignment

  output:
    set id, file("*_cel_flagstat.qc"), file("*_op50_flagstat.qc") into Subsample_alignment_for_statistic
    set file("${id}_cel.bam"), file("${id}_op50.bam")
  script:
  """

    bowtie2 -p ${params.nb_threads} \
      --very-sensitive \
      --end-to-end \
      --no-mixed \
      -X 2000 \
      --met 1 \
      -x "${params.bowtie2_indexes}" \
      -q -1 "${read1}" -2 "${read2}" \
      | samtools view -bS -o "${id}_cel.bam" -

      samtools flagstat "${id}_cel.bam" > "${id}_cel_flagstat.qc"

    bowtie2 -p ${params.nb_threads} \
      --very-sensitive \
      --end-to-end \
      --no-mixed \
      -X 2000 \
      --met 1 \
      -x "${params.bowtie2_indexes_contam}" \
      -q -1 "${read1}" -2 "${read2}" \
      | samtools view -bS -o "${id}_op50.bam" -

      samtools flagstat "${id}_op50.bam" > "${id}_op50_flagstat.qc"

  """
}


Stats_results = Features_enrichment_for_statistics
    .join(Library_complexity_for_statistics)
    .join(Subsample_alignment_for_statistic)
    .join(Bam_for_stats_mito_percent)
    .join(Nb_aligned_pairs_for_stats)
    .join(Reads_bed_format_for_bam_stats)


process ATAC__statistics_on_aligned_reads {
  tag "${id}"

  container = params.samtools_bedtools_perl

  // publishDir path: "${out_processed}/1_Preprocessing/ATAC/1_reads/5_metrics/4_intermediate_files", mode: "${pub_mode}"

  when: do_atac

  input:
    set id, file(features_enrichment), file(library_complexity), file(cel_flagstat), file(op50_flagstat), file(bam), file(bai), file(nb_aligned_pairs), file(nb_total_pairs), file(final_bed) from Stats_results

  output:
  file("*_bam_stats.txt") into Stats_on_aligned_reads_for_gathering

  shell:
  '''

    id=!{id}
    features_enrichment=!{features_enrichment}
    library_complexity=!{library_complexity}
    cel_flagstat=!{cel_flagstat}
    op50_flagstat=!{op50_flagstat}
    bam=!{bam}
    nb_aligned_pairs=!{nb_aligned_pairs}
    nb_total_pairs=!{nb_total_pairs}
    final_bed=!{final_bed}

    # number of paired end reads
    FINAL_PAIRS=`awk 'END{print NR/2}' ${final_bed}`
    ALIGNED_PAIRS=`basename ${nb_aligned_pairs} .NB_ALIGNED_PAIRS_${id}`
    RAW_PAIRS=`basename ${nb_total_pairs} .RAW_PAIRS_${id}`

    # percentage of aligned reads
    PERCENT_ALIGN_REF=`sed '7q;d' ${cel_flagstat} | cut -f 2 -d '(' | cut -f 1 -d '%'`
    PERCENT_ALIGN_OP50=`sed '7q;d' ${op50_flagstat} | cut -f 2 -d '(' | cut -f 1 -d '%'`

    # percentage of mitochondrial reads
    PERCENT_MITO=$(awk "BEGIN { print 100 * $(samtools view -c ${bam} MtDNA) / $(samtools view -c ${bam}) }" )

    # percentage of reads mapping to various annotated regions
    PERCENT_PROMOTERS=$(sed '3q;d' ${features_enrichment} | cut -f 1 -d ' ')
    PERCENT_EXONS=$(sed '3q;d' ${features_enrichment} | cut -f 2 -d ' ')
    PERCENT_INTRONS=$(sed '3q;d' ${features_enrichment} | cut -f 3 -d ' ')
    PERCENT_INTERGENIC=$(sed '3q;d' ${features_enrichment} | cut -f 4 -d ' ')
    PERCENT_GENIC=$(sed '3q;d' ${features_enrichment} | cut -f 5 -d ' ')

    # library size and percentage of duplicated reads 
    LIBRARY_SIZE=0
    RES_LIB_COMP=`sed '8q;d' ${library_complexity}`
    PERCENT_DUPLI=`echo $RES_LIB_COMP | cut -f 9 -d ' '`
    if [ "$PERCENT_DUPLI" = 0 ]; then
      LIBRARY_SIZE=0
    else
      LIBRARY_SIZE=`echo $RES_LIB_COMP | cut -f 10 -d ' '`
    fi
    PERCENT_DUPLI=`awk -v x=$PERCENT_DUPLI 'BEGIN {printf "%.2f\\n", 100 * x }' }`

    # gathering the results
    echo "${id},$PERCENT_MITO,$PERCENT_PROMOTERS,$PERCENT_EXONS,$PERCENT_INTRONS,$PERCENT_INTERGENIC,$PERCENT_GENIC,$PERCENT_ALIGN_REF,$PERCENT_ALIGN_OP50,$PERCENT_DUPLI,$LIBRARY_SIZE,$RAW_PAIRS,$ALIGNED_PAIRS,$FINAL_PAIRS" > ${id}_bam_stats.txt

  '''
}
// library size = library complexity
// # (=> needs aligned but not filtered reads)


// this process gather all individual statistics files and make a merged table 

process ATAC__gathering_statistics_on_aligned_reads {

  container = params.samtools_bedtools_perl

  publishDir path: "${out_dir}/Tables_Merged/1_Preprocessing", mode: "${pub_mode}"
  publishDir path: "${out_dir}/Tables_Individual/1_Preprocessing", mode: "${pub_mode}"

  when: do_atac

  input:
    file("*") from Stats_on_aligned_reads_for_gathering.collect()

  output:
    file("*.csv") into Bam_stat_for_splitting

  shell:
  '''
      OUTFILE="ATAC__alignment_statistics.csv"

      echo "LIBRARY_NAME,PERCENT_MITO,PERCENT_PROMOTERS,PERCENT_EXONS,PERCENT_INTRONS,PERCENT_INTERGENIC,PERCENT_GENIC,PERCENT_ALIGN_REF,PERCENT_ALIGN_OP50,PERCENT_DUPLI,LIBRARY_SIZE,RAW_PAIRS,ALIGNED_PAIRS,FINAL_PAIRS" > ${OUTFILE}

      cat *_bam_stats.txt >> ${OUTFILE}

   '''
}


process ATAC__splitting_statistics_for_multiqc {

  container = params.r_basic

  when: do_atac

  input:
    file(bam_stat_csv) from Bam_stat_for_splitting

  output:
    file("*") into Bam_stat_for_multiqc

  shell:
  '''

      #!/usr/bin/env Rscript


      library(magrittr)
      library(dplyr)

      bam_stat_csv = '!{bam_stat_csv}'


      df = read.csv(bam_stat_csv, stringsAsFactors = F)
      colnames(df) %<>% tolower %>% gsub('percent', 'percentage', .)

      df %<>% rename(percentage_mitochondrial = percentage_mito, percentage_align_reference = percentage_align_ref, percentage_aligned_OP50 = percentage_align_op50, percentage_duplications = percentage_dupli)

      colnames = colnames(df)[2:ncol(df)]
      for(colname in colnames){
        df1 = df[, c('library_name', colname)]
        write.csv(df1, row.names = F, file = paste0(colname, '_mqc.csv'))
      }


   '''
}



process ATAC__multiQC {

  container = params.multiqc

  publishDir path: "${out_dir}", mode: "${pub_mode}", saveAs: {
      if (it.indexOf(".html") > 0) "Figures_Individual/1_Preprocessing/${it}"
      else "Processed_Data/1_Preprocessing/ATAC__reads__multiQC/${it}"
  }

  publishDir path: "${out_dir}", mode: "${pub_mode}", saveAs: {
      if (it.indexOf(".html") > 0) "Figures_Merged/1_Preprocessing/${it}"
  }

  when: do_atac

  input:
    // val out_path from Channel.value('1_Preprocessing/ATAC/1_reads') 
    file ('fastqc/*') from FastQC_reports_before_trimming_for_multiQC.flatten().toList()
    file ('fastqc/*') from FastQC_reports_after_trimming_for_multiQC.flatten().toList()
    file(csv_files) from Bam_stat_for_multiqc

  output:
    file "ATAC__multiQC.html"
    file "*multiqc_data"

  script:
  """

    multiqc -f .
    mv multiqc_report.html ATAC__multiQC.html

  """
}

// This kind of commands could maybe make a more pretty multiqc report, but I would need to investigate more on how to do that exactly
// FILENAME=`basename bam_stats.csv .csv`
// cut -d "," -f 1-2 bam_stats.csv > ${FILENAME}_test_mqc.csv
//
// FILENAME=`basename ${bam_stat} .csv`
// cut -d "," -f 1-6 ${bam_stat} > \${FILENAME}_percentage_mqc.csv
// cut -d "," -f 1,7-10 ${bam_stat} > \${FILENAME}_counts_mqc.csv


//////////////////////////////////////////////////////////////////////////////
//// PEAKS ANNOTATION AND VISUALISATION

process ATAC__annotating_individual_peaks {

  tag "${id}"

  container = params.bioconductor

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__peaks__annotated_rds", mode: "${pub_mode}", enabled: save_all_bed

  when: do_atac

  input:
    set id, file(peaks) from Raw_peaks_for_annotations_in_R

  output:
    set id, file("*.rds") into Annotated_peaks_for_individual_plots, Annotated_peaks_for_collecting_as_lists

  when: params.do_raw_peak_annotation

  shell:
  '''

      #!/usr/bin/env Rscript

      library(ChIPseeker)
      id = '!{id}'
      upstream = !{params.promoter_up_macs2_peaks}
      downstream = !{params.promoter_down_macs2_peaks}
      tx_db <-  AnnotationDbi::loadDb('!{params.txdb}')
      peaks = readPeakFile('!{peaks}')

      promoter <- getPromoters(TxDb = tx_db, upstream = upstream, downstream = downstream)

      tag_matrix = getTagMatrix(peaks, windows = promoter)

      annotated_peaks = annotatePeak(peaks, TxDb = tx_db, tssRegion = c(-upstream, downstream), level = 'gene')

      genes = as.data.frame(annotated_peaks)$geneId

      lres = list(
        id = id,
        peaks = peaks,
        tag_matrix = tag_matrix,
        annotated_peaks = annotated_peaks,
        genes = genes
      )

      saveRDS(lres, file = paste0('annotated_peaks__', id, '.rds'))

  '''
}

// these are ATAC-Seq peaks from macs

// defaults parameters for the annotation function
// 1 function (peak, tssRegion = c(-3000, 3000), TxDb = NULL, level = "transcript", assignGenomicAnnotation = TRUE, genomicAnnotationPriority = c("Promoter", "5UTR", "3UTR", "Exon", "Intron", "Downstream", "Intergenic"), annoDb = NULL, addFlankGeneInfo = FALSE, flankDistance = 5000, sameStrand = FALSE, ignoreOverlap = FALSE, ignoreUpstream = FALSE, ignoreDownstream = FALSE, overlap = "TSS", verbose = TRUE)

// the addFlankGeneInfo gives rather confusing output so we ignore it
  // geneId          transcriptId distanceToTSS                                                     flank_txIds         flank_gene

// select(txdb, keys = keys(txdb)[1:1], columns = columns(txdb), keytype = 'GENEID')


Annotated_peaks_for_collecting_as_lists
  .map { it[1] }
  // .groupTuple () // legacy: before there was the option type that was equal to either "raw" or "norm", so we would group tupple this way. Now there is only "raw", so we just collect peaks
  .collect()
  .dump(tag:'anno_list') {"annotated peaks as list: ${it}"}
  .set { Annotated_peaks_for_collecting_as_lists1 }


process ATAC__plotting_individual_peak_files {
  tag "${id}"

  container = params.bioconductor

  publishDir path: "${out_fig_indiv}/${out_path}", mode: "${pub_mode}", saveAs: {
           if (it.indexOf("_coverage.pdf") > 0)        "ATAC__peaks__coverage/${it}"
      else if (it.indexOf("_average_profile.pdf") > 0) "ATAC__peaks__average_profile/${it}"
  }

  when: do_atac

  input:
    val out_path from Channel.value('1_Preprocessing') 
    set id, file(annotated_peaks_objects_rds) from Annotated_peaks_for_individual_plots

  output:
    set val("ATAC__peaks__coverage"), out_path, file("*_coverage.pdf") into ATAC_peaks_coverage_for_merging_pdfs
    set val("ATAC__peaks__average_profile"), out_path, file("*_average_profile.pdf") into ATAC_peaks_average_profile_for_merging_pdfs

  shell:
  '''

      #!/usr/bin/env Rscript
      library(ChIPseeker)
      library(ggplot2)

      id = '!{id}'
      upstream = !{params.promoter_up_macs2_peaks}
      downstream = !{params.promoter_down_macs2_peaks}
      lres = readRDS('!{annotated_peaks_objects_rds}')

      pdf(paste0(id, '__coverage.pdf'))
        covplot(lres$peaks, weightCol="V5") + ggtitle(id) + theme(plot.title = element_text(hjust = 0.5))
      dev.off()

      pdf(paste0(id, '__average_profile.pdf'))
        plotAvgProf(lres$tag_matrix, xlim=c(-upstream, downstream), xlab="Genomic Region (5'->3')", ylab = "Read Count Frequency") + ggtitle(id) + theme(plot.title = element_text(hjust = 0.5))
      dev.off()

  '''
}

Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_peaks_coverage_for_merging_pdfs.groupTuple(by: [0, 1]))
Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_peaks_average_profile_for_merging_pdfs.groupTuple(by: [0, 1]))




process ATAC__plotting_grouped_peak_files {

  container = params.bioconductor

  publishDir path: "${out_fig_indiv}/${out_path}/ATAC__peaks__grouped_plots", mode: "${pub_mode}"
  publishDir path: "${out_dir}/Figures_Merged/${out_path}", mode: "${pub_mode}"

  when: do_atac

  input:
    val out_path from Channel.value('1_Preprocessing') 
    file ("*") from Annotated_peaks_for_collecting_as_lists1

  output:
    file("*.pdf")

  shell:
  '''
      #!/usr/bin/env Rscript

      upstream = !{params.promoter_up_macs2_peaks}
      downstream = !{params.promoter_down_macs2_peaks}

      library(ChIPseeker)
      library(clusterProfiler)
      library(ggplot2)
      library(purrr)

      rds_files = list.files(pattern = '*.rds')
      lres = lapply(rds_files, readRDS)

      names0 = map_chr(lres, 'id')
      tag_matrix_list = map(lres, 'tag_matrix') %>% setNames(., names0)
      annotated_peaks_list = map(lres, 'annotated_peaks') %>% setNames(., names0)

      size_facet = ifelse(length(tag_matrix_list) > 12, 2.8, 5.5)

      p1 = plotAvgProf(tag_matrix_list, c(-upstream, downstream), facet='row')
      p1 = p1 + theme(axis.text.y = element_text(size = 3.5), strip.text.y = element_text(size = size_facet))

      pdf('ATAC__peaks__average_profile.pdf', font = 'mono')
        print(p1)
      dev.off()

      pdf('ATAC__peaks__annotation_barplot.pdf')
        plotAnnoBar(annotated_peaks_list)
      dev.off()

      pdf('ATAC__peaks__distance_to_TSS.pdf')
        plotDistToTSS(annotated_peaks_list)
      dev.off()


  '''
}



// //////////////////////////////////////////////////////////////////////////////
// //// DIFFENRENTIAL BINDING
// 
comparisons_files = file("design/comparisons.tsv")
Channel
  .from(comparisons_files.readLines())
  .map {
          m = it.split()
          condition1 = m[0]
          condition2 = m[1]
          [ condition1, condition2 ]
       }
  .dump(tag:'comp_file') {"comparison file: ${it}"}
  .into { comparisons_files_for_merging; comparisons_files_for_mRNA_Seq }

// regions_to_remove = file("design/regions_to_remove.tsv")
// Channel
//   .from(regions_to_remove)
//   // .from(regions_to_remove.readLines())
//   // .map { m = it.split(); [ m[0], m[1] ] }
//   .dump(tag:'regions_to_remove') {"regions to remove: ${it}"}
//   .set{regions_to_remove_for_merging}

Reads_for_diffbind
  .tap{ Reads_input_control }
  .join( Peaks_for_removing_specific_regions_1, remainder: true )
  .tap { channel_test }
  .map { [ it[0].split("_")[0], it[0..-1]] }
  .groupTuple()
  // .join(regions_to_remove_for_merging, remainder: true)
  // .combine(regions_to_remove_for_merging)
  .dump(tag:'reads_peaks') {"merged reads and peaks: ${it}"}
  .into { reads_and_peaks_1 ; reads_and_peaks_2 ; reads_and_peaks_3 }

regions_to_remove = Channel.fromPath( 'design/regions_to_remove.tsv' )

comparisons_files_for_merging
  .combine(reads_and_peaks_1)
  .combine(reads_and_peaks_2)
  .filter { id_comp_1, id_comp_2, id_1, reads_and_peaks_1, id_2, reads_and_peaks_2 -> id_comp_1 == id_1 && id_comp_2 == id_2 }
  .map { [ it[0] + '_vs_' + it[1], it.flatten().findAll { it =~ '\\.bed' }, it.flatten().findAll { it =~ "\\.bam" } ] }
  // .filter { id_comp_1, id_comp_2, id_1, reads_and_peaks_1, regions_to_remove_1, id_2, reads_and_peaks_2, regions_to_remove_2 -> id_comp_1 == id_1 && id_comp_2 == id_2 }
  // .map { [ it[0] + '_vs_' + it[1], it[4,7].join('__'), it.flatten().findAll { it =~ '\\.bed' }, it.flatten().findAll { it =~ "\\.bam" } ] }
  .tap { Reads_for_diffbind_1 }
  .map { it[0,1] }
  .combine(regions_to_remove)
  .dump(tag:'clean_peaks') {"peaks for removing regions: ${it}"}
  .set { Peaks_for_removing_specific_regions_2 }



process ATAC__removing_specific_regions {
  tag "${COMP}"

  container = params.samtools_bedtools_perl

  publishDir path: "${out_processed}/1_Preprocessing/ATAC__peaks__split__no_BL_input_RNAi", mode: "${pub_mode}", enabled: save_last_bed

  when: do_atac

  input:
      set COMP, file(bed_files), regions_to_remove from Peaks_for_removing_specific_regions_2
      // path regions_to_remove_file from regions_to_remove

  output:
      set COMP, file("*.bed") into Peaks_for_diffbind


  shell:
  '''

      COMP="!{COMP}"
      RTR="!{regions_to_remove}"
      BED_FILES="!{bed_files}"

      COMP1="${COMP/_vs_/|}"
      echo $COMP1 | grep -E -f - $RTR > rtr_filtered.txt

      cat rtr_filtered.txt | sed "s/,//g" | sed "s/.*->//g" | sed "s/[:-]/\\t/g" | sed "s/chr//g" > rtr_filtered_formatted.txt 

      for FILE in ${BED_FILES}
      do
        CUR_NAME=`basename $FILE ".bed"`
        intersectBed -v -a $FILE -b rtr_filtered_formatted.txt > "${CUR_NAME}_filtered.bed"
      done

  '''

}

// cat rtr_filtered.txt | sed "s/,//g" | sed "s/.*->//g" | sed "s/[:-]/\\t/g" | sed "s/chr//g" > rtr_filtered_formatted.txt 
// echo $COMP2 | grep -f - $RTR >> rtr_filtered.txt


// note: the reason why this process is here and not upstread is because we want to remove in all bed files the peaks that are in specific regions (i.e. RNAi) that we want to avoid. This is because, Diffbind will consider all peaks for his analysis, so if we remove one such peak in just one of the two samples to compare, then it will likely be found as differential bound during the DBA 


Reads_input_control
  .filter{ id, bam_files -> id == 'input'}
  .set{ Reads_input_control_1 }

Reads_for_diffbind_1
  .map { it[0,2] }
  .join(Peaks_for_diffbind)
  .dump(tag:'bam_bai') {"bam and bai files: ${it}"}
  .branch {
    with_input_control: params.use_input_control
    without_input_control: true
  }
  .set { Reads_and_peaks_for_diffbind_1 }

Reads_and_peaks_for_diffbind_1.with_input_control
  .combine(Reads_input_control_1)
  .map{ comp_id, bam_files, bed_files, input_id, imput_bam -> [ comp_id, bed_files, [bam_files, imput_bam].flatten() ] }
  // .map{ it -> [ it[0], it[1], [it[2,4].flatten()]] }
  .set{ Reads_and_peaks_with_input_control }

Reads_and_peaks_for_diffbind_1.without_input_control
  .concat(Reads_and_peaks_with_input_control)
  .dump(tag:'input_diffbind') {"reads and peaks for diffbind: ${it}"}
  .set{ Reads_and_peaks_for_diffbind_2 }







// This process generates the set of all peaks found in all replicates, and the set of differentially abundant/accessible peaks (can also be called differentially bound regions)

process ATAC__differential_abundance_analysis {
  tag "${COMP}"

  container = params.diffbind
  // container = params.multi_bioconductor
  // container = params.differential_abundance
  // Error in loadNamespace(x) : there is no package called ‘edgeR’

  publishDir path: "${out_processed}/2_Differential_Abundance", mode: "${pub_mode}", saveAs: {
     if (it.indexOf("__all_peaks.bed") > 0) "ATAC__all_peaks__bed/${it}"
     else if (it.indexOf("__diffbind_peaks_dbo.rds") > 0) "ATAC__all_peaks__DiffBind/${it}"
     else if (it.indexOf("__diffbind_peaks_gr.rds") > 0) "ATAC__all_peaks__gRange/${it}"
  }

  when: do_atac

  input:
      set COMP, file(bed), file(bam) from Reads_and_peaks_for_diffbind_2

  output:
      set COMP, file('*__diffbind_peaks_dbo.rds') into Diffbind_object_for_plotting
      set COMP, file('*__diffbind_peaks_gr.rds'), file('*__diffbind_peaks_dbo.rds') into All_peaks_for_peak_annotation
      set COMP, file('*__all_peaks.bed') into All_detected_ATAC_peaks_for_background

  shell:
  '''

        #!/usr/bin/env Rscript

        ##### loading data and libraries

        library(DiffBind)
        library(magrittr)
        library(parallel)

        COMP = '!{COMP}'
        use_input_control = '!{params.use_input_control}'
        source('!{projectDir}/bin/export_df_to_bed.R')
        cur_seqinfo = readRDS('!{params.cur_seqinfo}')

        conditions = strsplit(COMP, '_vs_')[[1]]
        cond1 = conditions[1]
        cond2 = conditions[2]


        ##### Preparing the metadata table
        use_input_control %<>% toupper %>% as.logical
        cur_files = grep('diffbind_peaks', list.files(pattern = '*.bam$|*filtered.bed$'), value = T, invert = T)
        df = data.frame(path = cur_files, stringsAsFactors=F)
        cursplit = sapply(cur_files, strsplit, '_')
        df$condition = sapply(cursplit, '[[', 1)
        df$replicate = sapply(cursplit, '[[', 2)
        df$id = paste0(df$condition, '_', df$replicate)
        df$id[df$condition == 'input'] = 'input'
        df$type = sapply(df$path, function(c1) ifelse(length(grep('reads', c1)) == 1, 'reads', ifelse(length(grep('peaks', c1)) == 1, 'peaks', '')))

        names_df1 = c('SampleID', 'Condition', 'Replicate', 'bamReads', 'ControlID', 'bamControl', 'Peaks','PeakCaller')
        all_id = unique(df$id) %>% .[. != 'input']
        df1 = data.frame(matrix(nrow = length(all_id), ncol = length(names_df1)), stringsAsFactors=F)
        names(df1) = names_df1

        for(c1 in 1:length(all_id)){
          cur_id = all_id[c1]
          sel_reads = which(df$id == cur_id & df$type == 'reads')
          sel_peaks = which(df$id == cur_id & df$type == 'peaks')

          df1$SampleID[c1] = cur_id
          df1$Condition[c1] = df$condition[sel_reads]
          df1$Replicate[c1] = df$replicate[sel_reads]
          df1$bamReads[c1] = df$path[sel_reads]
          df1$Peaks[c1] = df$path[sel_peaks]
          df1$PeakCaller[c1] = 'bed'

          if(use_input_control){
            sel_input_control_reads = which(df$condition == 'input' & df$type == 'reads')
            df1$ControlID[c1] = df$id[sel_input_control_reads]
            df1$bamControl[c1] = df$path[sel_input_control_reads]
          } else {
            df1$ControlID <- NULL
            df1$bamControl <- NULL
          }
        }


        ##### Running DiffBind

        dbo <- dba(sampleSheet = df1, minOverlap = 1)
        if(use_input_control) dbo <- dba.blacklist(dbo, blacklist = F, greylist = cur_seqinfo)
        dbo$config$RunParallel = F
        dbo$config$singleEnd = T
        dbo <- dba.count(dbo, bParallel = F, bRemoveDuplicates = FALSE, fragmentSize = 1, minOverlap = 1, score = DBA_SCORE_NORMALIZED, bUseSummarizeOverlaps = F, bSubControl = F, minCount = 1, summits = 75)
        dbo$config$AnalysisMethod = DBA_DESEQ2 
        dbo <- dba.normalize(dbo, normalize = DBA_NORM_RLE, library = DBA_LIBSIZE_BACKGROUND,  background = TRUE)
        dbo <- dba.contrast(dbo, categories = DBA_CONDITION, minMembers = 2)
        dbo <- dba.analyze(dbo, bBlacklist = F, bGreylist = F, bReduceObjects = FALSE)

        saveRDS(dbo, paste0(COMP, '__diffbind_peaks_dbo.rds'))

        
        ##### Exporting all peaks as a data frame

        # extracting all peaks (note: th is the fdr threshold, so with th = 1 we keep all peaks)
        all_peaks_gr = suppressWarnings(dba.report(dbo, th = 1))

        # recomputing the FDR to have more precise values (DiffBind round them at 3 digits)
        all_peaks_gr$FDR <- NULL
        all_peaks_gr$padj = p.adjust(data.frame(all_peaks_gr)$p.value, method = 'BH')

        # adding the raw reads counts of each replicate
        cp_raw = dba.peakset(dbo, bRetrieve = TRUE, score = DBA_SCORE_READS)
        mcols(cp_raw) = apply(mcols(cp_raw), 2, round, 2)
        m <- findOverlaps(all_peaks_gr, cp_raw)
        names_subject = names(mcols(cp_raw))
        mcols(all_peaks_gr)[queryHits(m), names_subject] = mcols(cp_raw)[subjectHits(m), names_subject]
        saveRDS(all_peaks_gr, paste0(COMP, '__diffbind_peaks_gr.rds'))


        ##### Exporting all peaks as a bed file

        all_peaks_df = as.data.frame(all_peaks_gr)
        all_peaks_df %<>% dplyr::mutate(name = rownames(.), score = round(-log10(p.value), 2))
        all_peaks_df %<>% dplyr::rename(chr = seqnames)
        all_peaks_df %<>% dplyr::select(chr, start, end, name, score, strand)
        export_df_to_bed(all_peaks_df, paste0(COMP, '__all_peaks.bed'))


    '''
}

////// justification for the parameters used

//// dba: minOverlap = 1
// could be set to 1 (any peak), or 2 peaks present in at least 2 peak set. The latter is much more stringent in situations where one has only 2 replicates per condition, which is why I decided to go with 1 for now.
// https://support.bioconductor.org/p/57809/

//// grey list is applied only if we have an input control as the greylist is made based on the input control sample. It is applied at the very beginning to filter out the grey regions from the start.

//// dbo$config$AnalysisMethod = DBA_DESEQ2 
// https://support.bioconductor.org/p/98736/
// For normalization, edgeR uses the TMM method which relies on a core of sites that don't systematically change their binding affinities. While this assumption of usually true for RNA-seq, there are many ChIP-seq experiments where one sample group has a completely different binding profile than the other sample group. Often, in one condition there is very little binding, but in the other condition much additional binding has been induced. ...  This is the reason we changed the default analysis method in DiffBind from edgeR to DESeq2.

//// dba.count: summits = 75
// DiffBind Vignette
// When forming the global binding matrix consensus peaksets, DiﬀBind ﬁrst identiﬁes all unique
// peaks amongst the relevant peaksets. As part of this process, it merges overlapping peaks,
// replacing them with a single peak representing the narrowest region that covers all peaks
// that overlap by at least one base. There are at least two consequences of this that are worth
// noting.
// First, as more peaksets are included in analysis, the average peak width tends to become
// longer as more overlapping peaks are detected and the start/end points are adjusted outward
// to account for them. Secondly, peak counts may not appear to add up as you may expect
// due to merging. For example, if one peakset contains two small peaks near to each other,
// while a second peakset includes a single peak that overlaps both of these by at least one
// base, these will all be replaced in the merged matrix with a single peak. As more peaksets
// are added, multiple peaks from multiple peaksets may be merged together to form a single,
// wider peak. Use of the "summits" parameter is recommended to control for this widening
// eﬀect.
// ?dba.count
// summits: unless set to ‘FALSE’, summit heights (read pileup) and
// locations will be calculated for each peak.  
// If the value of ‘summits’ is ‘TRUE’ (or ‘0’), the summits
// will be calculated but the peaksets will be unaffected.  If
// the value is greater than zero, all consensus peaks will be
// re-centered around a consensus summit, with the value of
// ‘summits’ indicating how many base pairs to include upstream
// and downstream of the summit (so all consensus peaks will be
// of the same width, namely ‘2 * summits + 1’).
// https://support.bioconductor.org/p/9138959/
// "Generally, ATAC-seq benefits from using the summits parameter at a relatively low value (50 or 100) to focus on clear regions of open chromatin with less background signal. Note that often there are two "peaks" in ATAC fragment lengths."
// => by setting summits to 75, the summits of the consensus peaks will be extende by 75 bp on both side. 

//// dba.count: fragmentSize = 1, bUseSummarizeOverlaps = F
//// dbo$config$singleEnd = T
// ?dba.count
// bUseSummarizeOverlaps: logical indicating that ‘summarizeOverlaps’
//           should be used for counting instead of the built-in counting
//           code.  This option is slower but uses the more standard
//           counting function. If ‘TRUE’, all read files must be BAM
//           (.bam extension), with associated index files (.bam.bai
//           extension).  The ‘fragmentSize’ parameter must absent.
// fragmentSize: This value will be used as the length of the reads.  Each
//           read will be extended from its endpoint along the appropriate
//           strand by this many bases.  If set to zero, the read size
//           indicated in the BAM/BED file will be used. ‘fragmentSize’
//           may also be a vector of values, one for each ChIP sample plus
//           one for each unique Control library.
// https://support.bioconductor.org/p/9138959/
// The fragmentSize parameter is only used if you have single-end data (otherwise the paired-end insert size is used). In that case, it is a good idea to specify a value for this parameter to "extend" the single-end reads by the mean fragment size.
// bUseSummarizeOverlaps=TRUE is generally the preferred option. If it is set to FALSE, it will use some internal code that, among other things, does not match paired-end reads, resulting in counts that may be up to double (each end counted separately). That option also gives you more fine-grained control over how the counting is done via $config parameters.
// => we do want each pair to be analyzed separately. And we want to keep reads at 1 bp as this is the most precise signal we have (transposase-shifted 5' end of reads)



//// dbo <- dba.normalize(dbo, normalize = DBA_NORM_LIB, )
// https://support.bioconductor.org/p/p133577/

//// dba.normalize: 


//// dba.normalize: normalize = DBA_NORM_RLE, library = DBA_LIBSIZE_BACKGROUND,  background = TRUE
// => background
// help(dba.normalize)
// background: This parameter controls the option to use "background"
//           bins, which should not have differential enrichment between
//           samples, as the basis for normalizing (instead of using reads
//           counts overlapping consensus peaks).  When enabled, the
//           chromosomes for which there are peaks in the consensus
//           peakset are tiled into large bins and reads overlapping these
//           bins are counted.
//
// Vignette:
// An assumption in RNA-seq analysis, that the read count matrix reﬂects an unbiased repre-
// sentation of the experimental data, may be violated when using a narrow set of consensus
// peaks that are chosen speciﬁcally based on their rates of enrichment. It is not clear that
// using normalization methods developed for RNA-seq count matrices on the consensus reads
// will not alter biological signals; it is probably a good idea to avoid using the consensus count matrix (Reads in Peaks) for normalizing unless there is a good prior reason to expect balanced changes in binding.
// https://support.bioconductor.org/p/p133577/
// If you are getting different results, it is likely that there is a systematic shift in enriched regions in one of the conditions. Unless you have a specific reason to believe this is due to technical issues, this is likely a biological signal you want to retain. In this case, you should NOT use RLE on the binding matrix.
// DBA_NORM_LIB is a quick way to perform a minimal normalization. I would try:
// normalize <- dba.normalize(CTCF_narrowpeakscount, method = DBA_DESEQ2, 
//                            normalize = DBA_NORM_RLE,  background=TRUE)
// to run RLE against background bins rather than the binding matrix.
// This should probably be the default, but computing the background bins is somewhat compute intensive.
// => normalize
// Vignette:
// # About normalization
// DiﬀBind relies on three underlying core methods for normalization. These include the "na-
// tive" normalization methods supplied with DESeq2 and edgeR , as well as a simple library-
// based method. The normalization method is speciﬁed with the normalize parameter to
// dba.normalize
// The native DESeq2 normalization method is based on calculating the geometric mean for
// each gene across samples[6], and is referred to "RLE" or DBA_NORM_RLE in DiﬀBind .
// The native edgeR normalization method is based on the trimmed mean of M-values approach[7],
// and is referred to as "TMM" or DBA_NORM_TMM in DiﬀBind .
// A third method is also provided that avoids making any assumptions regarding the distribution
// of reads between binding sites in diﬀerent samples that may be speciﬁc to RNA-seq analysis
// and inappropriate for ChIP-seq analysis. This method ( "lib" or DBA_NORM_LIB ) is based on
// the diﬀerent library sizes for each sample, computing normalization factors to weight each
// sample so as to appear to have the same library size. For DESeq2 , this is accomplished
// by dividing the number of reads in each library by the mean library size. For edgeR , the
// normalization factors are all set to 1.0 , indicating that only library-size normalization should occur.
// Note that any of these normalization methods can be used with either the DESeq2 or
// edgeR analysis methods, as DiﬀBind converts normalization factors to work appropriately
// in either DESeq2 or edgeR .


//// Other references
// https://support.bioconductor.org/p/86594/
// https://support.bioconductor.org/p/107679/


// note: it may be better to use a fragment size of 150 together with the slopBed 75 bp shifted reads. Need to check that in more details some day. For now "fragmentSize = 1" should be good enough.




// cut -f1,1 ctl_2_peaks_kept_after_blacklist_removal_filtered.bed | sort | uniq // X


// I get this error with the fly test dataset:
// Error in estimateSizeFactorsForMatrix(counts(object), locfunc = locfunc,  : 
//   every gene contains at least one zero, cannot compute log geometric means
// https://www.biostars.org/p/440379/

// df_tmp = data.frame(dba.peakset(dbo, bRetrieve = TRUE, score = DBA_SCORE_TMM_READS_FULL_CPM))
// data.frame(df_tmp)[, 6:ncol(df_tmp)]
// which(apply(data.frame(df_tmp)[, 6:ncol(df_tmp)], 1, function(x) all(x == 0)))
 
// here is the description of the changes: https://bioconductor.org/packages/release/bioc/news/DiffBind/NEWS

// # cur_greylist <- dba.blacklist(dbo, Retrieve=DBA_GREYLIST)


// ?dba.count
// bSubControl: logical indicating whether Control read counts are
//           subtracted for each site in each sample. If there are more
//           overlapping control reads than ChIP reads, the count will be
//           set to the ‘minCount’ value specified when ‘dba.count’ was
//           called, or zero if no value is specified.
// 
//           If ‘bSubControl’ is not explicitly specified, it will be set
//           to ‘TRUE’ unless a greylist has been applied (see
//           ‘dba.blacklist’).



// adding bUseSummarizeOverlaps = F to the dba.count call. This way we count as before, with 1 bp fragment length as it should be.
// https://rdrr.io/bioc/DiffBind/man/dba.count.html

// => removing the creation of a dbo1 object; the score DBA_SCORE_READS is obtained with the subsequent call to dba.peakset
// >         dbo1 <- dba.count(dbo, bParallel = F, bRemoveDuplicates = FALSE, fragmentSize = 1, minOverlap = 0, score = DBA_SCORE_READS)
// Warning message:
// In dba.count(dbo, bParallel = F, bRemoveDuplicates = FALSE, fragmentSize = 1,  :
//   No action taken, returning passed object...


// TO DO: make the blacklist/greylist removal work
// https://rdrr.io/bioc/DiffBind/man/dba.blacklist.html
// https://bioconductor.org/packages/release/data/annotation/html/BSgenome.Celegans.UCSC.ce11.html

// this fails
// https://support.bioconductor.org/p/p133830/
// dbo <- dba.blacklist(dbo, blacklist = F, greylist = seqinfo(BSgenome.Celegans.UCSC.ce11))


// > seqinfo(BSgenome.Celegans.UCSC.ce11)
// Seqinfo object with 7 sequences (1 circular) from ce11 genome:
//   seqnames seqlengths isCircular genome
//   chrI       15072434      FALSE   ce11
//   chrII      15279421      FALSE   ce11
//   chrIII     13783801      FALSE   ce11
//   chrIV      17493829      FALSE   ce11
//   chrV       20924180      FALSE   ce11
//   chrX       17718942      FALSE   ce11
//   chrM          13794       TRUE   ce11

// cat ~/workspace/cactus/data/worm/genome/sequence/chromosome_size.txt
// I       15072434
// II      15279421
// III     13783801
// IV      17493829
// V       20924180
// X       17718942

// => this is why the command fails


// # note: I also disable bScaleControl since it is used only to normalize controls reads prior to the substraction with bSubControl. But since we don't do that anymore and use greylist it doesn't matter so we can remove this parameter
// https://support.bioconductor.org/p/69924/

// # About normalization
// DiﬀBind relies on three underlying core methods for normalization. These include the "na-
// tive" normalization methods supplied with DESeq2 and edgeR , as well as a simple library-
// based method. The normalization method is speciﬁed with the normalize parameter to
// dba.normalize
// The native DESeq2 normalization method is based on calculating the geometric mean for
// each gene across samples[6], and is referred to "RLE" or DBA_NORM_RLE in DiﬀBind .
// The native edgeR normalization method is based on the trimmed mean of M-values approach[7],
// and is referred to as "TMM" or DBA_NORM_TMM in DiﬀBind .
// A third method is also provided that avoids making any assumptions regarding the distribution
// of reads between binding sites in diﬀerent samples that may be speciﬁc to RNA-seq analysis
// and inappropriate for ChIP-seq analysis. This method ( "lib" or DBA_NORM_LIB ) is based on
// the diﬀerent library sizes for each sample, computing normalization factors to weight each
// sample so as to appear to have the same library size. For DESeq2 , this is accomplished
// by dividing the number of reads in each library by the mean library size. For edgeR , the
// normalization factors are all set to 1.0 , indicating that only library-size normalization should occur.
// Note that any of these normalization methods can be used with either the DESeq2 or
// edgeR analysis methods, as DiﬀBind converts normalization factors to work appropriately
// in either DESeq2 or edgeR .

// DBA_NORM_NATIVE: equal DBA_NORM_TMM for edgeR and DBA_NORM_RLE for DESeq2


// => it is in fact recommended to use greylist regions instead of substracting controls! We update the code accordingly
// https://support.bioconductor.org/p/97717/
// https://github.com/crazyhottommy/ChIP-seq-analysis/blob/master/part3_Differential_binding_by_DESeq2.md
// https://support.bioconductor.org/p/72098/#72173

// From the Diffbind manual it also says:
// Another way of thinking about greylists is that they are one way of using the information in
// the control tracks to improve the reliability of the analysis. Prior to version 3.0, the default
// in DiﬀBind has been to simply subtract control reads from ChIP reads in order to dampen
// the magnitude of enrichment in anomalous regions. Greylists represent a more principled way
// of accomplishing this. If a greylist has been applied, the current default in DiﬀBind is to not
// subtract control reads.


// we should keep the bFullLibrarySize parameter to TRUE
// The issue is how the data are normalized. Setting bFullLibrarySize=FALSE uses a standard RNA-seq normalization method (based on the number of reads in consensus peaks), which assumes that most of the "genes" don't change expression, and those that do are divided roughly evenly in both directions. Using the default bFullLibrarySize=TRUE avoids these assumptions and does a very simple normalization based on the total number of reads for each library.

// THe bTagwise argument should not be needed but we keep it just in case and to be clearer
// Next edgeR::estimateGLMTrendedDisp is called with the DGEList and a design matrix derived
// from the design formula. By default, edgeR::estimateGLMTagwiseDisp is called next; this
// can be bypassed by setting DBA$config$edgeR$bTagwise=FALSE . 15

// the diffbind package changed a lot since the version I was using. The contrast command should be changed, and the dba.analyze command too. I will need to read in more details the method
// dbo <- dba.contrast(dbo, ~Condition, minMembers = 2)
// Error in dba.analyze(dbo, bTagwise = FALSE, bFullLibrarySize = TRUE, bSubControl = TRUE,  :
//   unused arguments (bTagwise = FALSE, bFullLibrarySize = TRUE, bSubControl = TRUE)


// here is the description of the changes: https://bioconductor.org/packages/release/bioc/news/DiffBind/NEWS
  // Changes in version 3.0     

  // - Moved edgeR bTagwise parameter to $config option
  // - Remove normalization options bSubControl, bFullLibrarySize, filter, and filterFun from dba.analyze(), now set in dba.normalize().
  // - dba.normalize(): is a new function; - bSubControl default depend on presence of Greylist
  // - Default for bUseSummarizeOverlaps in dba.count is now TRUE
  // 
  // 	The previous methods for modelling are maintained for backward
  // 	compatibility, however they are not the default.  To repeat
  // 	earlier analyses, dba.contrast() must be called explicitly with
  // 	design=FALSE. See ?DiffBind3 for more information.
  // 
  //   The default mode for dba.count() is now to center around
  //   summits (resulting in 401bp intervals).  To to avoid
  //   recentering around summits as was the previous default, set
  //   summits=FALSE (or to a more appropriate value).
  // 
  //   Normalization options have been moved from dba.analyze() to the
  //   new interface function dba.normalize(). Any non-default
  //   normalization options must be specified using dba.normalize().

// from the manuel:
//   2. bFullLibrarySize: This is now part of the library parameter for dba.normalize . li
// brary=DBA_LIBSIZE_FULL is equivalent to bFullLibrarySize=TRUE , and library=DBA_LIBSIZE_PEAKREADS
// is equivalent to bFullLibrarySize=FALSE .

// from the R help:
// DBA_LIBSIZE_FULL: Full library size (all reads in library)
// DBA_LIBSIZE_PEAKREADS: Library size is Reads in Peaks


// rtracklayer::export(promoters, 'promoters.bed')

// note: diffbind_peaks: means the peaks from diffbind, not that these peaks are diffbound (differentially bound). This set is in fact all the peaks that diffbind found in all replicates. The corresponding bed file will be used as a control for downstream enrichment tasks (CHIP, motifs, chromatin states).


process ATAC__annotating_all_peaks {
  tag "${COMP}"

  container = params.bioconductor

  publishDir path: "${out_processed}/2_Differential_Abundance", mode: "${pub_mode}", saveAs: {
     if (it.indexOf("_df.rds") > 0) "ATAC__all_peaks__dataframe/${it}"
     else if (it.indexOf("_cs.rds") > 0) "ATAC__all_peaks__ChIPseeker/${it}"
  }

  when: do_atac

  input:
    set COMP, file(diffbind_peaks_gr), file(diffbind_peaks_dbo) from All_peaks_for_peak_annotation

  output:
    file('*.rds')
    set COMP, file("*_df.rds") into Annotated_peaks_for_saving_tables, Annotated_peaks_for_plotting
    set COMP, file("*_df.rds"), file(diffbind_peaks_dbo) into Diffbind_object_and_peaks_anno_for_plotting

  when: params.do_diffbind_peak_annotation

  shell:
  '''
      #!/usr/bin/env Rscript


      ##### loading data and libraries

      library(GenomicFeatures)
      library(ChIPseeker)
      library(magrittr)

      COMP = '!{COMP}'
      tx_db <- loadDb('!{params.txdb}')
      df_genes_metadata = readRDS('!{params.df_genes_metadata}')
      upstream = !{params.promoter_up_diffbind_peaks}
      downstream = !{params.promoter_down_diffbind_peaks}
      diffbind_peaks_gr = readRDS('!{diffbind_peaks_gr}')


      ##### annotating all peaks

      # annotating peaks
      anno_peak_cs = annotatePeak(diffbind_peaks_gr, TxDb = tx_db, tssRegion = c(-upstream, downstream), level = 'gene')
      ROWNAMES(anno_peak_cs)
      anno_peak_cs = annotatePeak(diffbind_peaks_gr, TxDb = tx_db, tssRegion = c(-upstream, downstream), level = 'gene', overlap = 'all')
      

      # creating data frame
      anno_peak_gr = anno_peak_cs@anno
      df = as.data.frame(anno_peak_gr)
      anno_peak_df = cbind(peak_id = rownames(df), df, anno_peak_cs@detailGenomicAnnotation)
      anno_peak_df$peak_id %<>% as.character %>% as.integer


      ##### saving all peaks

      name0 = paste0(COMP, '__diffb_anno_peaks')
      saveRDS(anno_peak_df, paste0(name0, '_df.rds'))
      saveRDS(anno_peak_cs, paste0(name0, '_cs.rds'))

  '''
}

// cs: for ChIPseeker
// rtracklayer::export(anno_peak_df, paste0(name0, '.bed'))
// these are peaks of differential chromatin accessibility called by DiffBind

// note that in df_annotated_peaks: the geneStart and geneEnd field reflect actually the transcript start and transcript end. This is if the level = 'transcript' option is used. If the option level = 'gene' is used then the coordinates correspond to gene. (same goes for distanceToTSS, genLength...)



//////////////////////////////////////////////////////////////////////////////
//// MRNA SEQ

process mRNA__fastqc {
  tag "${id}"

  container = params.fastqc

  publishDir path: "${out_dir}/Processed_Data/1_Preprocessing/mRNA__fastqc", mode: "${pub_mode}"

  when: do_mRNA

  input:
    set id, file(reads) from MRNA_reads_for_fastqc

  output:
    file("*.{zip, html}") into FastQC_reports_for_multiQC

  script:
  """

  fastqc -t 2 ${reads}

  """

}


process mRNA__MultiQC {

  container = params.multiqc

  publishDir path: "${out_dir}", mode: "${pub_mode}", saveAs: {
    if (it.indexOf(".html") > 0) "Figures_Individual/1_Preprocessing/${it}"
    else "Processed_Data/1_Preprocessing/mRNA__multiQC/${it}"
  }
  publishDir path: "${out_dir}", mode: "${pub_mode}", saveAs: {
    if (it.indexOf(".html") > 0) "Figures_Merged/1_Preprocessing/${it}"
  }

  when: do_mRNA

  input:
    // val out_path from Channel.value('1_Preprocessing/mRNA') 
    file ('fastqc/*') from FastQC_reports_for_multiQC.flatten().toList()

  output:
    set "mRNA__multiQC.html", "*multiqc_data" optional true

  script:
  """

    multiqc -f .
    mv multiqc_report.html mRNA__multiQC.html

  """
}

MRNA_reads_for_kallisto
  .map{ it.flatten() }
  .map{ [it[0], it[1..-1] ] }
  .dump(tag:'atac_kallisto') {"ATAC peaks for kallisto: ${it}"}
  .set { MRNA_reads_for_kallisto2 }



process mRNA__mapping_with_kallisto {
    tag "${id}"

    container = params.kallisto

    publishDir path: "${out_processed}/1_Preprocessing/mRNA__kallisto_output", mode: "${pub_mode}"

    when: do_mRNA

    input:
    set id, file(reads) from MRNA_reads_for_kallisto2

    output:
    set id, file("kallisto_${id}") into Kallisto_out_for_sleuth

    script:

        def single = reads instanceof Path
        if( single ) {
            """
              mkdir kallisto_${id}
              kallisto quant --single -l ${params.fragment_len} -s ${params.fragment_sd} -b ${params.bootstrap} -i ${params.kallisto_transcriptome} -t ${params.nb_threads} -o kallisto_${id} ${reads}
            """
        }
        else {
            """
              mkdir kallisto_${id}
              kallisto quant -b ${params.bootstrap} -i ${params.kallisto_transcriptome} -t ${params.nb_threads} -o kallisto_${id} ${reads}
            """
        }
}

// note: I adapted a basic mRNA-Seq pipeline from https:////github.com/cbcrg/kallisto-nf



// making the groups for differential gene expression

Kallisto_out_for_sleuth
  .map{ [ it[0].split('_')[0], it[1] ] }
  .groupTuple()
  .into{ Kallisto_out_for_sleuth1; Kallisto_out_for_sleuth2 }

Kallisto_out_for_sleuth1
  .combine(Kallisto_out_for_sleuth2)
  .map { it[0,2,1,3]}
  .dump(tag:'kalisto_sleuth') {"${it}"}
  .join(comparisons_files_for_mRNA_Seq, by: [0,1])
  .map{
    def list = []
    list.add( it[0,1].join('_vs_') )
    list.addAll( it[0..3] )
    return(list)
    }
  .set { Kallisto_out_for_sleuth3 }


// estimate differential gene expression

process mRNA__differential_abundance_analysis {
    tag "${COMP}"

    container = params.sleuth

    publishDir path: "${out_processed}/2_Differential_Abundance", mode: "${pub_mode}", saveAs: {
         if (it.indexOf("__mRNA_DEG_rsleuth.rds") > 0) "mRNA__all_genes__rsleuth/${it}"
         else if (it.indexOf("__mRNA_DEG_df.rds") > 0) "mRNA__all_genes__dataframe/${it}"
      else if (it.indexOf("__all_genes_prom.bed") > 0) "mRNA__all_genes__bed_promoters/${it}"
    }

    when: do_mRNA

    input:
      set COMP, cond1, cond2, file(kallisto_cond1), file(kallisto_cond2) from Kallisto_out_for_sleuth3

    output:
      set COMP, file('*__mRNA_DEG_rsleuth.rds') into Rsleuth_object_for_plotting
      set COMP, file('*__mRNA_DEG_df.rds') into MRNA_diffab_genes_for_saving_tables
      set COMP, file('*__all_genes_prom.bed') into All_detected_genes_promoters_for_background

    shell:
    '''
      #!/usr/bin/env Rscript

      library(sleuth)
      library(ggplot2)
      library(magrittr)

      df_genes_transcripts = readRDS('!{params.df_genes_transcripts}')
      df_genes_metadata = readRDS('!{params.df_genes_metadata}')

      COMP = '!{COMP}'
      cond1 = '!{cond1}'
      cond2 = '!{cond2}'

      promoters_df = readRDS('!{params.promoters_df}')
      source('!{projectDir}/bin/export_df_to_bed.R')
      source('!{projectDir}/bin/get_prom_bed_df_table.R')


      s2c = data.frame(path = dir(pattern = paste('kallisto', '*')), stringsAsFactors = F)
      s2c$sample = sapply(s2c$path, function(x) strsplit(x, 'kallisto_')[[1]][2])
      s2c$condition = sapply(s2c$path, function(x) strsplit(x, '_')[[1]][2])
      levels(s2c$condition) = c(cond1, cond2)

  		test_cond = paste0('condition', cond2)
  		cond <- factor(s2c$condition)
  		cond <- relevel(cond, ref = cond2)
  		md <- model.matrix(~cond, s2c)
  		colnames(md)[2] <- test_cond

      t2g <- dplyr::rename(df_genes_transcripts, target_id = TXNAME, gene_id = GENEID)
      t2g$target_id %<>% paste0('transcript:', .)

      # Load the kallisto data, normalize counts and filter genes
		  sleo <- sleuth_prep(sample_to_covariates = s2c, full_model = md, target_mapping = t2g, aggregation_column = 'gene_id', transform_fun_counts = function(x) log2(x + 0.5), gene_mode = T)

      # Estimate parameters for the sleuth response error measurement (full) model
      sleo <- sleuth_fit(sleo)

      # Performing test and saving the sleuth object
      sleo <- sleuth_wt(sleo, test_cond)
      saveRDS(sleo, file = paste0(COMP, '__mRNA_DEG_rsleuth.rds'))

      # saving as dataframe and recomputing the FDR
      res <- sleuth_results(sleo, test_cond, test_type = 'wt', pval_aggregate  = F)
      res %<>% .[!is.na(.$b), ]
      res$padj = p.adjust(res$pval, method = 'BH')
      res$qval <- NULL
      res %<>% dplyr::rename(gene_id = target_id)
      res1 = dplyr::inner_join(df_genes_metadata, res, by = 'gene_id')
      saveRDS(res1, file = paste0(COMP, '__mRNA_DEG_df.rds'))

      # exporting promoters of all detected genes
      promoters_df1 = promoters_df
      promoters_df1 %<>% .[.$gene_id %in% res1$gene_id, ]
      prom_bed_df = get_prom_bed_df_table(promoters_df1, res1)
      export_df_to_bed(prom_bed_df, paste0(COMP, '__all_genes_prom.bed'))


    '''
}

// with rsleuth v0.30
// length(which(is.na(res$b))) # 17437

// with rsleuth v0.29
// dim(res) # 2754   11 => NA values are automatically filtered out
// dim(df_genes_metadata) # 20191     8
// 20191 - 2754 # 17437

// sleuth_prep message
// 3252 targets passed the filter
// 2754 genes passed the filter

// the filtering function is the following:
// https://www.rdocumentation.org/packages/sleuth/versions/0.29.0/topics/basic_filter
// basic_filter(row, min_reads = 5, min_prop = 0.47)
// row        this is a vector of numerics that will be passedin
// min_reads  the minimum mean number of reads
// min_prop   the minimum proportion of reads to pass this filter

// note: we compute the FDR for both ATAC and mRNA seq to be sure to have consistent values generated by the same FDR method



//////////////////////////////////////////////////////////////////////////////
//// PLOTTING DA RESULTS (VOLCANO, PCA)


process plotting_differential_gene_expression_results {
    tag "${COMP}"

    publishDir path: "${out_fig_indiv}/${out_path}", mode: "${pub_mode}", saveAs: { 
          if (it.indexOf("__mRNA_volcano.pdf") > 0) "mRNA__volcano/${it}"
          else if (it.indexOf("__mRNA_PCA_1_2.pdf") > 0) "mRNA__PCA_1_2/${it}"
          else if (it.indexOf("__mRNA_PCA_3_4.pdf") > 0) "mRNA__PCA_3_4/${it}"
          else if (it.indexOf("__mRNA_other_plots.pdf") > 0) "mRNA__other_plots/${it}"
    }


    container = params.sleuth

    input:
      val out_path from Channel.value('2_Differential_Abundance')
      set COMP, file(mRNA_DEG_rsleuth_rds) from Rsleuth_object_for_plotting

    output:
      set val("mRNA__volcano"), out_path, file('*__mRNA_volcano.pdf') into MRNA_Volcano_for_merging_pdfs
      set val("mRNA__PCA_1_2"), out_path, file('*__mRNA_PCA_1_2.pdf') into MRNA_PCA_1_2_for_merging_pdfs
      set val("mRNA__PCA_3_4"), out_path, file('*__mRNA_PCA_3_4.pdf') into MRNA_PCA_3_4_for_merging_pdfs
      set val("mRNA__other_plots"), out_path, file('*__mRNA_other_plots.pdf') into MRNA_Other_plot_for_merging_pdfs

    shell:
    '''
      #!/usr/bin/env Rscript


      ##### Loading libraries and data

      library(sleuth)
      library(ggplot2)
      library(magrittr)
      library(grid)

      source('!{projectDir}/bin/functions_plot_volcano_PCA.R')

      sleo = readRDS('!{mRNA_DEG_rsleuth_rds}')
      df_genes_metadata = readRDS('!{params.df_genes_metadata}')

      COMP = '!{COMP}'
      conditions = strsplit(COMP, '_vs_')[[1]]
      cond1 = conditions[1]
      cond2 = conditions[2]
      test_cond = paste0('condition', cond2)

      FDR_threshold = !{params.fdr_threshold_sleuth_plots}



      ##### volcano plots

      res_volcano <- sleuth_results(sleo, test_cond)
      res_volcano %<>% dplyr::rename(gene_id = target_id, L2FC = b)
      df_genes_metadata_1 = df_genes_metadata[, c('gene_id', 'gene_name')]
      res_volcano %<>% dplyr::inner_join(df_genes_metadata_1, by = 'gene_id')
      res_volcano %<>% dplyr::mutate(padj = p.adjust(pval, method = 'BH'))

      pdf(paste0(COMP, '__mRNA_volcano.pdf'))
        plot_volcano_custom(res_volcano, sig_level = FDR_threshold, label_column = 'gene_name', title = paste(COMP, 'mRNA'))
      dev.off()


      ##### PCA plots

      # the pca is computed using the default parameters in the sleuth functions sleuth::plot_pca
      mat = sleuth:::spread_abundance_by(sleo$obs_norm_filt, 'scaled_reads_per_base')
      prcomp1 <- prcomp(mat)
      v_gene_id_name = df_genes_metadata_1$gene_name %>% setNames(., df_genes_metadata_1$gene_id)
      rownames(prcomp1$x) %<>% v_gene_id_name[.]

      lp_1_2 = get_lp(prcomp1, 1, 2, paste(COMP, ' ', 'mRNA'))
      lp_3_4 = get_lp(prcomp1, 3, 4, paste(COMP, ' ', 'mRNA'))

      pdf(paste0(COMP, '__mRNA_PCA_1_2.pdf'))
        make_4_plots(lp_1_2)
      dev.off()

      pdf(paste0(COMP, '__mRNA_PCA_3_4.pdf'))
        make_4_plots(lp_3_4)
      dev.off()


      ##### other plots

      pdf(paste0(COMP, '__mRNA_other_plots.pdf'))
        plot_ma(sleo, test = test_cond, sig_level = FDR_threshold) + ggtitle(paste('MA:', COMP))
        plot_group_density(sleo, use_filtered = TRUE, units = "scaled_reads_per_base", trans = "log", grouping = setdiff(colnames(sleo$sample_to_covariates), "sample"), offset = 1) + ggtitle(paste('Estimated counts density:', COMP))
        # plot_scatter(sleo) + ggtitle(paste('Scatter:', COMP))
        # plot_fld(sleo, 1) + ggtitle(paste('Fragment Length Distribution:', COMP))
      dev.off()


    '''
}

Merging_pdf_Channel = Merging_pdf_Channel.mix(MRNA_Volcano_for_merging_pdfs.groupTuple(by: [0, 1]))
Merging_pdf_Channel = Merging_pdf_Channel.mix(MRNA_PCA_1_2_for_merging_pdfs.groupTuple(by: [0, 1]))
Merging_pdf_Channel = Merging_pdf_Channel.mix(MRNA_PCA_3_4_for_merging_pdfs.groupTuple(by: [0, 1]))
Merging_pdf_Channel = Merging_pdf_Channel.mix(MRNA_Other_plot_for_merging_pdfs.groupTuple(by: [0, 1]))




process plotting_differential_accessibility_results {
  tag "${COMP}"

  container = params.diffbind
  // container = params.differential_abundance
  // container = params.multi_bioconductor

  publishDir path: "${out_fig_indiv}/${out_path}", mode: "${pub_mode}", saveAs: {
         if (it.indexOf("_volcano.pdf") > 0) "ATAC__volcano/${it}"
         else if (it.indexOf("_PCA_1_2.pdf") > 0) "ATAC__PCA_1_2/${it}"
         else if (it.indexOf("_PCA_3_4.pdf") > 0) "ATAC__PCA_3_4/${it}"
         else if (it.indexOf("_other_plots.pdf") > 0) "ATAC__other_plots/${it}"
  }
  publishDir path: "${out_processed}/${out_path}", mode: "${pub_mode}", saveAs: {
        if (it.indexOf("__ATAC_non_annotated_peaks.txt") > 0) "ATAC__non_annotated_peaks/${it}"
      }
  

  input:
    val out_path from Channel.value('2_Differential_Abundance')
    set COMP, file(annotated_peaks), file(diffbind_object_rds) from Diffbind_object_and_peaks_anno_for_plotting

  output:
    set val("ATAC__volcano"), out_path, file('*__ATAC_volcano.pdf') into ATAC_Volcano_for_merging_pdfs
    set val("ATAC__PCA_1_2"), out_path, file('*__ATAC_PCA_1_2.pdf') into ATAC_PCA_1_2_for_merging_pdfs
    set val("ATAC__PCA_3_4"), out_path, file('*__ATAC_PCA_3_4.pdf') into ATAC_PCA_3_4_for_merging_pdfs
    set val("ATAC__other_plots"), out_path, file('*__ATAC_other_plots.pdf') into ATAC_Other_plot_for_merging_pdfs
    file("*__ATAC_non_annotated_peaks.txt")

  shell:
  '''

      #!/usr/bin/env Rscript


      ##### loading data and libraries

      library(ggplot2)
      library(magrittr)
      library(grid)
      library(DiffBind)

      source('!{projectDir}/bin/functions_plot_volcano_PCA.R')

      COMP = '!{COMP}'

      dbo = readRDS('!{diffbind_object_rds}')
      FDR_threshold = !{params.fdr_threshold_diffbind_plots}
      dbo$config$th = FDR_threshold
      df_genes_metadata = readRDS('!{params.df_genes_metadata}')
      df_annotated_peaks = readRDS('!{annotated_peaks}')



      ##### volcano plots

      res = df_annotated_peaks %>% dplyr::rename(L2FC = Fold, gene_id = geneId)
      df_genes_metadata_1 = df_genes_metadata[, c('gene_id', 'gene_name')]
      res %<>% dplyr::inner_join(df_genes_metadata_1, by = 'gene_id')

      pdf(paste0(COMP, '__ATAC_volcano.pdf'))
        plot_volcano_custom(res, sig_level = FDR_threshold, label_column = 'gene_name', title = paste(COMP, 'ATAC'))
      dev.off()


      ##### PCA plots

      # Handling unnanotated peaks
      v_gene_names = res$gene_name[match(1:nrow(dbo$binding), res$peak_id)]
      sel = which(is.na(v_gene_names))
      v_gene_names[is.na(v_gene_names)] = paste0('no_gene_', 1:length(sel))
      sink(paste0(COMP, '__ATAC_non_annotated_peaks.txt'))
        print(dbo$peaks[[1]][sel,])
      sink()
      
      # doing and plotting the PCA
      prcomp1 <- DiffBind__pv_pcmask__custom(dbo, nrow(dbo$binding), cor = F, bLog = T)$pc
      rownames(prcomp1$x) = v_gene_names

      lp_1_2 = get_lp(prcomp1, 1, 2, paste(COMP, ' ', 'ATAC'))
      lp_3_4 = get_lp(prcomp1, 3, 4, paste(COMP, ' ', 'ATAC'))

      pdf(paste0(COMP, '__ATAC_PCA_1_2.pdf'))
        make_4_plots(lp_1_2)
      dev.off()

      pdf(paste0(COMP, '__ATAC_PCA_3_4.pdf'))
        make_4_plots(lp_3_4)
      dev.off()


      ##### other plots

      pdf(paste0(COMP, '__ATAC_other_plots.pdf'))
          dba.plotMA(dbo, bNormalized = T)
          dba.plotHeatmap(dbo, main = 'all reads')
          first_2_replicates = sort(c(which(dbo$masks$Replicate.1), which(dbo$masks$Replicate.2)))
          dba.plotVenn(dbo, mask = first_2_replicates, main = 'all reads')
      dev.off()


  '''

}

Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_Volcano_for_merging_pdfs.groupTuple(by: [0, 1]))
Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_PCA_1_2_for_merging_pdfs.groupTuple(by: [0, 1]))
Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_PCA_3_4_for_merging_pdfs.groupTuple(by: [0, 1]))
Merging_pdf_Channel = Merging_pdf_Channel.mix(ATAC_Other_plot_for_merging_pdfs.groupTuple(by: [0, 1]))

// DiffBind__pv_pcmask__custom was adapted from DiffBind::pv.pcmask. This little hacking is necessary because DiffBind functions plots PCA but do not return the object.
// alternatively, the PCA could be made from scratch as done here: https://support.bioconductor.org/p/76346/




//////////////////////////////////////////////////////////////////////////////
//// SAVING AND SPLITTING DIFFERENTIAL ABUNDANCE RESULTS


process mRNA__saving_detailed_results_tables {
    tag "${COMP}"

    container = params.r_basic

    publishDir path: "${out_tab_indiv}/2_Differential_Abundance/mRNA", mode: pub_mode, enabled: params.save_tables_as_csv

    when: do_mRNA

    input:
    set COMP, file(mRNA_DEG_df) from MRNA_diffab_genes_for_saving_tables

    output:
    // set val('2_DA__mRNA_detailed_table'), file('*.rds') into MRNA_detailed_tables_for_merging_tables
    set val('mRNA_detailed'), val('2_Differential_Abundance'), file('*.rds') into MRNA_detailed_tables_for_formatting_table
    set COMP, file('*.rds') into MRNA_detailed_tables_for_splitting_in_subsets

    shell:
    '''
      #!/usr/bin/env Rscript


      ##### Loading libraries and data

      library(magrittr)

      COMP = '!{COMP}'

      mRNA_DEG_df = readRDS('!{mRNA_DEG_df}')


      ##### Saving a detailed results table
      res_detailed = mRNA_DEG_df
      res_detailed %<>% dplyr::rename(L2FC = b)
      res_detailed$COMP = COMP
      res_detailed %<>% dplyr::select(COMP, chr, start, end, width, strand, gene_name, gene_id, entrez_id, pval, padj, L2FC, dplyr::everything())
      saveRDS(res_detailed, paste0(COMP, '__res_detailed_mRNA.rds'))


    '''
}


// Merging_tables_Channel = Merging_tables_Channel.mix(MRNA_detailed_tables_for_merging_tables.groupTuple())
// Merging_tables_Channel = Merging_tables_Channel.mix(MRNA_detailed_tables_for_merging_tables.groupTuple())
Formatting_tables_Channel = Formatting_tables_Channel.mix(MRNA_detailed_tables_for_formatting_table)


// Diffbind_object_for_plotting
//   .join(Annotated_peaks_for_plotting)
//   // format: COMP, diffbind_object, annotated_peaks
//   .dump(tag:'input_diffbind_plot') {"diffbing object and annotated peaks: ${it}"}
//   .tap{ Diffbind_object_and_peaks_anno_for_plotting }
//   .join(MRNA_simple_table_for_merging_with_ATAC)
//   // format: COMP, diffbind_object, annotated_peaks, mRNA_simple_table
//   .set{ Dbo_peak_anno_mrna_table_for_DAR_table }






process ATAC__saving_detailed_results_tables {
  tag "${COMP}"

  container = params.r_basic

  // publishDir path: "${out_tab_indiv}/2_Differential_Abundance/ATAC", mode: pub_mode, enabled: params.save_tables_as_csv

  when: do_atac

  input:
    set COMP, file(annotated_peaks) from Annotated_peaks_for_saving_tables

  output:
    // set val('2_DA__ATAC_detailed_table'), file("*.rds") into ATAC_detailed_tables_for_merging_tables
    set val('ATAC_detailed'), val('2_Differential_Abundance'), file('*.rds') into ATAC_detailed_tables_for_formatting_table
    set COMP, file("*.rds") into ATAC_detailed_tables_for_splitting_in_subsets

  shell:
  '''

      #!/usr/bin/env Rscript

      ##### loading data and libraries

      library(magrittr)
      library(purrr)

      COMP = '!{COMP}'

      df_annotated_peaks = readRDS('!{annotated_peaks}')
      df_genes_metadata = readRDS('!{params.df_genes_metadata}')

      source('!{projectDir}/bin/get_merged_columns.R')


      # setting up parameters
      conditions = tolower(strsplit(COMP, '_vs_')[[1]])
      cond1 = conditions[1]
      cond2 = conditions[2]

      # creating the res_detailed table
      res_detailed = df_annotated_peaks
      # adding gene metadata in a more readable format than what provided by default by ChIPseeker
      df_genes_metadata1 = dplyr::rename(df_genes_metadata, gene_chr = chr, gene_start = start, gene_end = end, gene_width = width, gene_strand = strand)
      res_detailed %<>% dplyr::select(-geneChr, -geneStart, -geneEnd, -geneLength, -geneStrand)
      colnames(res_detailed) %<>% tolower
      res_detailed %<>% dplyr::rename(gene_id = geneid)
      res_detailed %<>% dplyr::inner_join(df_genes_metadata1, by = 'gene_id')

      # renaming columns
      res_detailed %<>% dplyr::rename(chr = seqnames, L2FC = fold, pval = p.value, distance_to_tss = distancetotss, five_UTR = fiveutr, three_UTR = threeutr)
      res_detailed$COMP = COMP

      # collapsing replicates values and renaming these columns as well
      colnames(res_detailed)[grep('conc_', colnames(res_detailed))] = c('conc_cond1', 'conc_cond2')
      colns = colnames(res_detailed)
      colns1 = grep(paste0('^', cond1, '_'), colns)
      colns2 = grep(paste0('^', cond2, '_'), colns)
      res_detailed$counts_cond1 = apply(res_detailed[, colns1], 1, paste, collapse = '|')
      res_detailed$counts_cond2 = apply(res_detailed[, colns2], 1, paste, collapse = '|')
      res_detailed[, c(colns1, colns2)] <- NULL

      # reordering columns
      res_detailed$strand <- NULL  # strand information is not available for ATAC-Seq
      res_detailed %<>% dplyr::select(COMP, peak_id, chr, start, end, width, gene_name, gene_id, pval, padj, L2FC, distance_to_tss, annotation, conc, conc_cond1, conc_cond2, counts_cond1, counts_cond2, dplyr::everything())

      # adding the filtering columns
      res_detailed %<>% dplyr::mutate(
        FC_up = L2FC > 0,
        FC_down = L2FC < 0,

        PF_8kb = abs(distance_to_tss) < 8000,
        PF_3kb = abs(distance_to_tss) < 3000,
        PF_2u1d = distance_to_tss > -2000 & distance_to_tss < 1000,
        PF_TSS = distance_to_tss == 0,
        PF_genProm = genic | promoter,
        PF_genic = genic,
        PF_prom = promoter,
        PF_distNC = distal_intergenic | ( intron & !promoter & !five_UTR  & !three_UTR  & !exon)
      )

      # saving table
      saveRDS(res_detailed, paste0(COMP, '__res_detailed_atac.rds'))


  '''

}

// Merging_tables_Channel = Merging_tables_Channel.mix(ATAC_detailed_tables_for_merging_tables
//     .groupTuple()
//     .map{ [ it[0], it[1].flatten() ] }
//     ).dump(tag: 'test_chan1')


// Merging_tables_Channel = Merging_tables_Channel.mix(ATAC_detailed_tables_for_merging_tables.groupTuple())    
Formatting_tables_Channel = Formatting_tables_Channel.mix(ATAC_detailed_tables_for_formatting_table)




if(params.experiment_types == 'mRNA'){
  MRNA_detailed_tables_for_splitting_in_subsets
  .set{ Diff_abundance_res_tables_for_splitting_in_subsets }
}

if(params.experiment_types == 'atac'){
  ATAC_detailed_tables_for_splitting_in_subsets
  .set{ Diff_abundance_res_tables_for_splitting_in_subsets }
}

if(params.experiment_types == 'both'){
  ATAC_detailed_tables_for_splitting_in_subsets
  // format: COMP, res_detailed_atac
  .mix(MRNA_detailed_tables_for_splitting_in_subsets)
  // format: COMP, res_detailed_(atac or mRNA)
  // .join(MRNA_detailed_tables_for_splitting_in_subsets)
  // // format: COMP, res_detailed_atac, res_detailed_mRNA
  .groupTuple()
  // format: COMP, [ res_detailed_atac, res_detailed_mRNA ]
  .dump(tag: 'both_data')
  .set{ Diff_abundance_res_tables_for_splitting_in_subsets }
}

do_mRNA_lgl = do_mRNA.toString().toUpperCase()
do_atac_lgl = do_atac.toString().toUpperCase()


process splitting_differential_abundance_results_in_subsets {
  tag "${COMP}"

  container = params.r_basic

  publishDir path: "${out_processed}/2_Differential_Abundance", mode: "${pub_mode}", saveAs: {
    if (it.indexOf("__genes.rds") > 0) "DA_split__genes_rds/${it}"
    else if   (it.indexOf(".bed") > 0) "DA_split__bed_regions/${it}"
  }

  // publishDir path: "${out_dir}", mode: pub_mode, enabled: params.save_tables_as_csv, saveAs: {
  //   if      (it.indexOf("__res_simple.csv") > 0) "Tables_Individual/2_Differential_Abundance/res_simple/${it}"
  //   else if (it.indexOf("__res_filter.csv") > 0) "Tables_Individual/2_Differential_Abundance/res_filter/${it}"
  // }

  input:
    set COMP, file(res_detailed) from Diff_abundance_res_tables_for_splitting_in_subsets

  output:
    set val('res_simple'), val('2_Differential_Abundance'), file("*__res_simple.rds") into Both_simple_table_for_formatting_table optional true
    set val('res_filter'), val('2_Differential_Abundance'), file("*__res_filter.rds") into Both_filter_table_for_formatting_table optional true
    // set val('2_DA__both_simple_table'), file("*__res_simple.rds") into Both_simple_table_for_merging_tables optional true
    // set val('2_DA__both_filter_table'), file("*__res_filter.rds") into Both_filter_table_for_merging_tables optional true
    set COMP, file("*__genes.rds") into DA_genes_split_for_enrichment_analysis optional true
    set COMP, file("*__regions.bed") into DA_regions_split_for_enrichment_analysis optional true


  shell:
  '''

      #!/usr/bin/env Rscript

      ##### loading data and libraries
      library(magrittr)
      library(purrr)

      source('!{projectDir}/bin/read_from_nextflow.R')
      source('!{projectDir}/bin/export_df_to_bed.R')
      source('!{projectDir}/bin/get_prom_bed_df_table.R')
      source('!{projectDir}/bin/get_merged_columns.R')

      COMP = '!{COMP}'

      do_mRNA = !{do_mRNA_lgl}
      do_atac = !{do_atac_lgl}
      do_both = do_mRNA & do_atac

      lf = list.files()

      promoters_df = readRDS('!{params.promoters_df}')

      FDR_split = read_from_nextflow('!{params.fdr_for_splitting_subsets}') %>% as.numeric
      FC_split = read_from_nextflow('!{params.fold_changes_for_splitting_subsets}')
      PF_split = read_from_nextflow('!{params.peak_assignment_for_splitting_subsets}')



      ################################
      # creating the res_simple table

      # combining atac and mRNA results
      if(do_atac) {
        res_detailed_atac = readRDS(grep('atac.rds', lf, value = T))

        # adding the aggregated PF filter column
        res_detailed_atac$PF_all = T
        PF_columns_all = grep('PF_', colnames(res_detailed_atac), value = T)
        res_detailed_atac$PF = get_merged_columns(res_detailed_atac, paste0('PF_', PF_split), 'PF')

        res_simple_atac = res_detailed_atac %>% dplyr::mutate(transcript_id = NA, ET = 'ATAC') %>% dplyr::select(COMP, peak_id, chr, gene_name, gene_id, pval, padj, L2FC, PF, ET)
        res_simple = res_simple_atac
      }

      if(do_mRNA) {
        res_detailed_mRNA = readRDS(grep('mRNA.rds', lf, value = T))
        res_simple_mRNA = res_detailed_mRNA %>% dplyr::select(COMP, chr, gene_name, gene_id, pval, padj, L2FC)
        res_simple_mRNA = cbind(peak_id = 'Null', res_simple_mRNA, ET = 'mRNA', PF = 'Null', stringsAsFactors = F)
        res_simple_mRNA %<>% dplyr::select(COMP, peak_id, chr, gene_name, gene_id, pval, padj, L2FC, PF, ET)
        res_simple = res_simple_mRNA
      }

      if(do_both) res_simple = rbind(res_simple_atac, res_simple_mRNA)

      # adding the aggregated FC filter column
      res_simple %<>% dplyr::mutate(FC_all = T, FC_up = L2FC > 0, FC_down = L2FC < 0)
      res_simple$FC = get_merged_columns(res_simple, paste0('FC_', FC_split), 'FC')

      # adding the aggregated FDR filter column
      for(fdr in FDR_split) res_simple[[paste0('FDR_', fdr)]] = res_simple$padj < 10^-fdr
      res_simple$FDR = get_merged_columns(res_simple, paste0('FDR_', FDR_split), 'FDR')
      res_simple$FDR %<>% gsub('^$', 'NS', .)  # NS: None Significant

      # filtering and reordering columns
      res_simple %<>% dplyr::select(ET, PF, FC, FDR, COMP, peak_id, chr, gene_name, gene_id, pval, padj, L2FC)

      saveRDS(res_simple, paste0(COMP, '__res_simple.rds'))


      ################################
      ## creating the res_filter table

      df_split = expand.grid(FDR = FDR_split, FC = FC_split, PF = PF_split, stringsAsFactors = F)
      lres_filter = list()

      for(c1 in 1:nrow(df_split)){
        FDR1 = df_split$FDR[c1]
        FC1 = df_split$FC[c1]
        PF1 = df_split$PF[c1]

        res_filter_atac = res_simple %>% dplyr::filter(grepl(FDR1, FDR) & grepl(FC1, FC) & grepl(PF1, PF) & ET == 'ATAC')
        res_filter_mRNA = res_simple %>% dplyr::filter(grepl(FDR1, FDR) & grepl(FC1, FC) & ET == 'mRNA')

        # adding the Experiment Type "both"
        ATAC_genes = res_filter_atac$gene_id
        mRNA_genes = res_filter_mRNA$gene_id
        both_genes = res_filter_atac$gene_id %>% .[. %in% mRNA_genes]

        res_filter_atac_both = res_filter_atac %>% dplyr::filter(gene_id %in% both_genes) %>% dplyr::mutate(ET = 'both_ATAC')
        res_filter_mRNA_both = res_filter_mRNA %>% dplyr::filter(gene_id %in% both_genes) %>% dplyr::mutate(ET = 'both_mRNA')

        res_filter_tmp = rbind(res_filter_atac_both, res_filter_mRNA_both, res_filter_atac, res_filter_mRNA)
        res_filter_tmp %<>% dplyr::mutate(FDR = FDR1, FC = FC1, PF = PF1)
        res_filter_tmp$PF[res_filter_tmp$ET == 'mRNA'] = 'Null'

        lres_filter[[c1]] = res_filter_tmp

      }

      res_filter = do.call(rbind, lres_filter)
      res_filter %<>% .[!duplicated(.), ]

      saveRDS(res_filter, paste0(COMP, '__res_filter.rds'))


      ################################
      ## splitting results in subsets and exporting as bed and gene lists

      if(do_atac) {
        atac_bed_df = res_detailed_atac
        atac_bed_df %<>% dplyr::mutate(score = round(-log10(padj), 2), name = paste(gene_name, peak_id, sep = '_'), strand = '*')
        atac_bed_df %<>% dplyr::select(chr, start, end, name, score, strand, gene_id)
      }

      if(do_mRNA) {
        promoters_df1 = promoters_df
        prom_bed_df = get_prom_bed_df_table(promoters_df1, res_simple_mRNA)
      }

      res_filter$gene_peak = apply(res_filter[, c('gene_name', 'peak_id')], 1, paste, collapse = '_')

      df_split1 = res_filter %>% dplyr::select(ET:FDR) %>% .[!duplicated(.),]

      for(c1 in 1:nrow(df_split1)){
        ET1  = df_split1$ET[c1]
        PF1  = df_split1$PF[c1]
        FC1  = df_split1$FC[c1]
        FDR1 = df_split1$FDR[c1]

        df = subset(res_filter, ET == ET1 & PF == PF1 & FC == FC1 & FDR == FDR1)
        DA_genes = unique(df$gene_id)
        NDA_genes = subset(res_simple, ET == ET1 & !gene_id %in% DA_genes, 'gene_id')$gene_id
        lgenes = list(DA = DA_genes, NDA = NDA_genes)

        key = paste(ET1, PF1, FC1, FDR1, COMP, sep = '__')

        # exporting bed files
        if(do_mRNA && ET1 %in% c('mRNA', 'both_mRNA')) {
          cur_bed = prom_bed_df %>% .[.$gene_id %in% DA_genes, ]
        }

        if(do_atac && ET1 %in% c('ATAC', 'both_ATAC')) {
          cur_bed = atac_bed_df %>% .[.$name %in% df$gene_peak, ]
        }

        bed_name = paste0(key, '__regions.bed')
        export_df_to_bed(cur_bed, bed_name)

        # exporting gene list
        key %<>% gsub('both_....', 'both', .)
        saveRDS(lgenes, paste0(key, '__genes.rds'))

      }


  '''

}

// bed_name = paste0(key, '__diff_expr_genes_prom.bed')
// bed_name = paste0(key, '__diff_ab_peaks.bed')


// Merging_tables_Channel = Merging_tables_Channel.mix(ATAC_detailed_tables_for_merging_tables.groupTuple())

// Merging_tables_Channel = Merging_tables_Channel.mix(Both_simple_table_for_merging_tables.groupTuple().map{ [ it[0], it[1].flatten() ] })

// Merging_tables_Channel = Merging_tables_Channel.mix(Both_simple_table_for_merging_tables.groupTuple())
// Merging_tables_Channel = Merging_tables_Channel.mix(Both_filter_table_for_merging_tables.groupTuple())

Formatting_tables_Channel = Formatting_tables_Channel.mix(Both_simple_table_for_formatting_table)
Formatting_tables_Channel = Formatting_tables_Channel.mix(Both_filter_table_for_formatting_table)




// Note: in the res_filter table, each entry is multiplied at maximum by the number of rows in the df_split table times 2 (for the ET column)

// why we remove 1bp at the start for bed export from a grange object
// https://www.biostars.org/p/89341/
// The only trick is remembering the BED uses 0-based coordinates.
// note that the df that are input to the function export_df_to_bed all come from a grange object (output of )






// ### Adding keys to genes sets

// note: there are slightly more items in the peaks channels, since the both sets are duplicated (both_ATAC and both_mRNA)


DA_genes_split_for_enrichment_analysis
  // COMP, [ multiple_rds_files ] (files format: path/ET__PF__FC__FDR__COMP__genes.rds)
  .tap{ DA_genes_for_venn_diagrams }
  .map{ it[1] }.flatten().toList()
  // [ all_rds_files ]
  .into{ DA_genes_list_for_self_overlap ; DA_genes_for_self_overlap0 }

DA_genes_for_self_overlap0
  .flatten()
  // one rds_file per line
  .map{ [ it.name.replaceFirst(~/__genes.*/, ''), it ] }
  // key (ET__PF__FC__FDR__COMP), rds_file
  .into{ DA_genes_for_self_overlap ; DA_genes_for_func_anno_overlap }


DA_genes_for_self_overlap
  // format: key (ET__PF__FC__FDR__COMP), rds_file (lgenes = list(DA, NDA))
  .combine(DA_genes_list_for_self_overlap)
  // format: key, rds_file, rds_files
  .map{ [ "${it[0]}__genes_self", 'genes_self', it[1], it[2..-1] ] }
  // format: key (ET__PF__FC__FDR__COMP__DT), DT, rds_file, [ rds_files ]
  .dump(tag: 'genes_self')
  .set{ DA_genes_for_self_overlap1 }



// ### Adding backgrounds to peak sets

// A background is needed for downstream analysis to compare DEG or DBP to all genes or all peaks. This background is all_peaks found by DiffBind for the ATAC and both_ATAC entries. And it is the promoters of genes detected by sleuth for mRNA and both_mRNA entries.

DA_regions_split_for_enrichment_analysis
  // COMP, multiple_bed_files (files format: path/ET__PF__FC__FDR__COMP__peaks.bed)
  .map{ it[1] }.flatten()
  // bed_file
  .map{ [ it.name.replaceFirst(~/__regions.bed/, ''), it ] }
  // key (ET__PF__FC__FDR__COMP), bed_file
  .dump(tag:'DA_regions')
  .into{ DA_regions_split_ATAC ; DA_regions_split_mRNA }

DA_regions_split_ATAC
  // key, DA_regions
  .filter{ it[0] =~ /.*ATAC.*/ }
  .combine(All_detected_ATAC_peaks_for_background)
  // key, DA_regions, COMP, all_peaks
  .dump(tag:'DA_regions_ATAC')
  .set{ DA_regions_split_ATAC1 }

DA_regions_split_mRNA
  .filter{ it[0] =~ /.*mRNA.*/ }
  .combine(All_detected_genes_promoters_for_background)
  // key, diff_expr_prom_bed, COMP, all_genes_prom_bed
  .dump(tag:'DA_regions_mRNA')
  .set{ DA_regions_split_mRNA1 }

DA_regions_split_ATAC1
  .mix(DA_regions_split_mRNA1)
  // format: key, DA_regions, all_regions
  .filter{ it[0].split('__')[4] ==~ it[2] }
  // keeping only entries for which the COMP match with the key
  .map{ it[0, 1, 3] }
  // key, DA_regions, all_regions
  .filter{ it[1].readLines().size() >= params.min_entries_DA_bed }
  // keeping only entries with more than N dif bound/expr regions
  .dump(tag:'DA_regions_with_bg')
  .into{ DA_regions_with_bg_for_bed_overlap ; DA_regions_with_bg_for_motifs_overlap }



//////////////////////////////////////////////////////////////////////////////
//// PLOTTING OVERLAP RESULTS




process plotting_venn_diagrams {
  tag "${COMP}"

  container = params.venndiagram

  publishDir path: "${out_fig_indiv}/2_Differential_Abundance", mode: "${pub_mode}", saveAs: {
      if (it.indexOf("__venn_up_or_down.pdf") > 0) "Venn_diagrams__two_ways/${it}"
      else if (it.indexOf("__venn_up_and_down.pdf") > 0) "Venn_diagrams__four_ways/${it}"
  }

  input:
    set COMP, file('*') from DA_genes_for_venn_diagrams

  output:
    set val("Venn_diagrams__two_ways"), val("2_Differential_Abundance"), file('*__venn_up_or_down.pdf')  into Venn_up_or_down_for_merging_pdfs optional true
    set val("Venn_diagrams__four_ways"), val("2_Differential_Abundance"), file('*__venn_up_and_down.pdf') into Venn_up_and_down_for_merging_pdfs optional true

  when: params.do_diffbind_peak_annotation

  shell:
  '''
      #!/usr/bin/env Rscript


      library(VennDiagram)

      source('!{projectDir}/bin/plot_venn_diagrams.R')


      all_files = list.files(pattern = '*.rds')

      df = data.frame(do.call(rbind, lapply(all_files, function(x) strsplit(x, '__')[[1]][-6])), stringsAsFactors = F)
      colnames(df) = c('ET', 'PF', 'FC', 'FDR', 'COMP')

      PFs = unique(df$PF)
      PFs = PFs[PFs != 'Null']
      FDRs = unique(df$FDR)
      COMP = df$COMP[1]

      get_file_name <- function(ET, PF, FC, FDR){
        paste(ET, PF, FC, FDR, COMP, 'genes.rds', sep = '__')
      }

      for(PF1 in PFs){
        for(FDR1 in FDRs){

          atac_up = get_file_name('ATAC', PF1, 'up', FDR1)
          atac_down = get_file_name('ATAC', PF1, 'down', FDR1)
          mrna_up = get_file_name('mRNA', 'Null', 'up', FDR1)
          mrna_down = get_file_name('mRNA', 'Null', 'down', FDR1)

          a_u = file.exists(atac_up)
          a_d = file.exists(atac_down)
          m_u = file.exists(mrna_up)
          m_d = file.exists(mrna_down)

          if(a_u & m_u) {
            lgenes = list(atac_up = readRDS(atac_up)$DA, mrna_up = readRDS(mrna_up)$DA)
            prefix = paste(PF1, 'up', FDR1, COMP, sep = '__')
            plot_venn_diagrams(lgenes, prefix)
          }

          if(a_d & m_d) {
            lgenes = list(atac_down = readRDS(atac_down)$DA, mrna_down = readRDS(mrna_down)$DA)
            prefix = paste(PF1, 'down', FDR1, COMP, sep = '__')
            plot_venn_diagrams(lgenes, prefix)
          }

          if(a_u & a_d & m_u & m_d) {
            lgenes = list(atac_up = readRDS(atac_up)$DA, mrna_up = readRDS(mrna_up)$DA, atac_down = readRDS(atac_down)$DA, mrna_down = readRDS(mrna_down)$DA)
            prefix = paste(PF1, FDR1, COMP, sep = '__')
            plot_venn_diagrams(lgenes, prefix)
          }

        }
      }


  '''
}

Merging_pdf_Channel = Merging_pdf_Channel.mix(Venn_up_or_down_for_merging_pdfs.groupTuple(by: [0, 1]).map{ it.flatten() }.map{ [ it[0], it[1], it[2..-1] ] })
Merging_pdf_Channel = Merging_pdf_Channel.mix(Venn_up_and_down_for_merging_pdfs.groupTuple(by: [0, 1]).map{ it.flatten() }.map{ [ it[0], it[1], it[2..-1] ] })




// importing groups of comparisons to plot together on the overlap matrix and the heatmaps

comparisons_grouped = file("design/groups.tsv")
Channel
  .from( comparisons_grouped.readLines() )
  .map { it.split() }
  .map { [ it[0], it[1..-1].join('|') ] }
  // .map { [ it[0], it[1..-1] ] }
  // format: GRP, [ comp_order ]
  .dump(tag:'comp_group') {"comparisons grouped: ${it}"}
  // .into { comparisons_grouped_for_overlap_matrix ; comparisons_grouped_for_heatmap }
  .set { comparisons_grouped_for_heatmap }




//////////////////////////////////////////////////////////////////////////////
//// ENRICHMENT ANALYSIS


//////////////////////////////////////////////////////////////////////////////
//// ENRICHMENT OF GENES SETS


DA_genes_for_func_anno_overlap
  // key (ET__PF__FC__FDR__COMP), rds_file
  .combine(params.func_anno_databases)
  // key (ET__PF__FC__FDR__COMP), rds_file, func_anno
  .map{ key, rds_file, func_anno -> 
    data_type = "func_anno_" + func_anno
    new_key = key + "__" + data_type
    [ new_key, data_type, func_anno, rds_file ]
  }
  // key (ET__PF__FC__FDR__COMP__DT), data_type, func_anno, rds_file 
  .dump(tag: 'func_anno')
  .set{ DA_genes_for_func_anno_overlap1 }


process compute_functional_annotations_overlap {
  tag "${key}"

  container = params.bioconductor

  // publishDir path: "${out_processed}/3_Enrichment/a_gene_set_enrichment", mode: "${pub_mode}"

  input:
    set key, data_type, func_anno, file(gene_set_rds) from DA_genes_for_func_anno_overlap1

  output:
    set key, data_type, file('*__counts.csv') into Genes_func_anno_count_for_computing_pvalue optional true

  when: params.do_gene_set_enrichment

  shell:
  '''

      #!/usr/bin/env Rscript

      library(clusterProfiler)
      library(magrittr)

      key = '!{key}'
      lgenes = readRDS('!{gene_set_rds}')
      func_anno = '!{func_anno}'
      org_db = AnnotationDbi::loadDb('!{params.org_db}')
      specie = '!{params.specie}'
      df_genes_metadata = readRDS('!{params.df_genes_metadata}')
      min_entries_DA_genes_sets = '!{params.min_entries_DA_genes_sets}'
      use_nda_as_bg_for_func_anno = !{params.use_nda_as_bg_for_func_anno}

      organism_key = switch(specie, worm = 'cel', fly = 'dme', mouse = 'mmu', human = 'hsa')


      gene_set_enrich <- function(lgenes, type){
        DA_genes = lgenes$DA
        universe = lgenes$NDA
        if(!use_nda_as_bg_for_func_anno) universe = NULL

        if(type == 'KEGG') {

          vec = df_genes_metadata$entrez_id %>% setNames(., df_genes_metadata$gene_id)
          gene_set_entrez = vec[DA_genes]

          res = enrichKEGG( gene = gene_set_entrez, pvalueCutoff = 1, qvalueCutoff  = 1, pAdjustMethod = 'BH', organism = organism_key, keyType = 'ncbi-geneid', universe = universe)
          if(is.null(res)) error('NULL output')
          res
        }
          else {
            simplify( enrichGO( gene = DA_genes, OrgDb = org_db, keyType = 'ENSEMBL', ont = type, pAdjustMethod = 'BH', pvalueCutoff = 1, qvalueCutoff  = 1, universe = universe), cutoff = 0.8, by = 'p.adjust', select_fun = min)
          }
      }

      robust_gene_set_enrich <- function(lgenes, type){
        tryCatch(gene_set_enrich(lgenes, type), error = function(e) {print(paste('No enrichment found'))})
      }

      res = robust_gene_set_enrich(lgenes, func_anno)

      if(class(res) == 'enrichResult') {
        df = res@result

        if(nrow(df) != 0) {

            # converting IDs from entrez to Ensembl
            if(func_anno == 'KEGG'){
              vec = df_genes_metadata$gene_id %>% setNames(., df_genes_metadata$entrez_id)
              ensembl_ids = purrr::map_chr(strsplit(df$geneID, '/'), ~ paste(unname(vec[.x]), collapse = '/'))
              df$geneID = ensembl_ids
            }

            # extracting count columns, reformatting and saving results
            df %<>% tidyr::separate(GeneRatio, c('ov_da', 'tot_da'), sep = '/')
            df %<>% tidyr::separate(BgRatio, c('ov_nda', 'tot_nda'), sep = '/')
            df[, c('ov_da', 'tot_da', 'ov_nda', 'tot_nda')] %<>% apply(2, as.integer)

            df %<>% dplyr::rename(tgt_id = ID, tgt = Description, genes_id = geneID)
            df %<>% dplyr::select(tgt, tot_da, ov_da, tot_nda, ov_nda, tgt_id, genes_id)

            write.csv(df, paste0(key, '__counts.csv'), row.names = F)

        }
      }

  '''
}

Counts_tables_Channel = Counts_tables_Channel.mix(Genes_func_anno_count_for_computing_pvalue)

// universe = ifelse(use_nda_as_bg_for_func_anno, lgenes$NDA, NULL) # => this fails: "error replacement has length zero"


process compute_genes_self_overlap {
  tag "${key}"

  container = params.r_basic

  input:
    set key, data_type, file(lgenes), file('all_gene_sets/*') from DA_genes_for_self_overlap1

  output:
    set key, data_type, file("*__counts.csv") into Genes_self_overlap_for_computing_pvalue

  // when: params.do_diffbind_peak_annotation

  shell:
  '''
        #!/usr/bin/env Rscript

        library(magrittr)

        key = '!{key}'
        lgenes = readRDS('!{lgenes}')

        DA = lgenes$DA
        NDA = lgenes$NDA

        all_gene_sets = list.files('all_gene_sets')
        all_gene_sets %<>% setNames(., gsub('__genes.rds', '', .))
        all_DA = purrr::map(all_gene_sets, ~readRDS(paste0('all_gene_sets/', .x))$DA)

        df = purrr::imap_dfr(all_DA, function(genes_tgt, target){
          tgt = target
          tot_tgt = length(genes_tgt)
          tot_da = length(DA)
          ov_da = length(intersect(DA, genes_tgt))
          tot_nda = length(NDA)
          ov_nda = length(intersect(NDA, genes_tgt))
          data.frame(tgt, tot_tgt, tot_da, ov_da, tot_nda, ov_nda)
        })

        write.csv(df, paste0(key, '__genes_self__counts.csv'), row.names = F)


  '''
}

Counts_tables_Channel = Counts_tables_Channel.mix(Genes_self_overlap_for_computing_pvalue)




//////////////////////////////////////////////////////////////////////////////
//// ENRICHMENT OF PEAKS SETS


(DA_regions_with_bg_for_bed_overlap1, DA_regions_with_bg_for_bed_overlap2) = DA_regions_with_bg_for_bed_overlap.into(2)

// CHIP_channel         = Channel.fromPath( "${params.encode_chip_files}/*bed" )    .toList().map{ [ 'CHIP'        , it ] }
CHIP_channel_all     = Channel.fromPath( "${params.encode_chip_files}/*bed" )
Chrom_states_channel = Channel.fromPath( "${params.chromatin_state_1}/*bed" ).toList().map{ [ 'chrom_states', it ] }
DA_regions_channel   = DA_regions_with_bg_for_bed_overlap1.map{ it[1] }    .toList().map{ [ 'peaks_self'  , it ] }

Channel
  .fromPath( params.chip_ontology_groups )
  .splitCsv( header: false, sep: '\t' )
  .filter{ group, chip_bed -> group == params.chip_ontology }
  .map{ [it[1], it[0] ] }
  .map{ [it[0] ] }
  // .view{ "CHIP ontology: $it" }
  .set{ chip_files_to_keep }
  
// Chrom_states_channel
//   .view{ "Chromatin state: $it" }

CHIP_channel_all
  .map{ [ it.name, it ] }
  .join(chip_files_to_keep)
  .map{ it[1] }
  .toList()
  .map{ [ 'CHIP', it ] }
  // .view{ "CHIP files: $it" }
  .set{ CHIP_channel }

// grep "CHIP file" nf_log.txt  | head
// grep "CHIP ontology" nf_log.txt  | head
// grep "Chromatin state" nf_log.txt  | head
// println "chromatin state file: ${params.chromatin_state_1}"
// println "chip ontology: ${params.chip_ontology}"


if( ! params.do_chromatin_state ) Chrom_states_channel.close()


Bed_regions_to_overlap_with = CHIP_channel.mix(Chrom_states_channel).mix(DA_regions_channel)

DA_regions_with_bg_for_bed_overlap2
  // format: key (ET__PF__FC__FDR__COMP), DA_regions, all_regions
  .combine(Bed_regions_to_overlap_with)
  // format: key, DA_regions, all_regions, data_type, bed_files
  .map{ [ it[0,3].join('__'), it[3], it[1], it[2], it[4] ] }
  .dump(tag:'bed_overlap')
  // format: key (ET__PF__FC__FDR__COMP__DT), data_type, DA_regions, all_regions, bed_files
  .set{ DA_regions_with_bg_and_bed_for_overlap }


process compute_peaks_self_overlap {
  tag "${key}"

  container = params.samtools_bedtools_perl

  input:
    set key, data_type, file(DA_regions), file(all_regions), file("BED_FILES/*") from DA_regions_with_bg_and_bed_for_overlap

  output:
    set key, data_type, file("*__counts.csv") into Peaks_self_overlap_for_computing_pvalue

  // when: params.do_chip_enrichment

  shell:
  '''

        DB=!{DA_regions}
        ALL=!{all_regions}
        KEY=!{key}

        intersectBed -v -a ${ALL} -b ${DB} > not_diffbound.bed
        NDB="not_diffbound.bed"

        tot_da=`wc -l < ${DB}`
        tot_nda=`wc -l < ${NDB}`

        OUTPUT_FILE="${KEY}__counts.csv"

        echo "tgt, tot_tgt, tot_da, ov_da, tot_nda, ov_nda" > $OUTPUT_FILE

        BEDS=($(ls BED_FILES))

        for BED1 in ${BEDS[@]}
          do
          	BED=BED_FILES/$BED1
            tgt=`basename ${BED} .bed`
            tgt=`basename ${tgt} __regions`
            tot_tgt=`wc -l < ${BED}`
            intersectBed -u -a ${DB} -b ${BED} > overlap_DB.tmp
            ov_da=`wc -l < overlap_DB.tmp`
            intersectBed -u -a ${NDB} -b ${BED} > overlap_NDB.tmp
            ov_nda=`wc -l < overlap_NDB.tmp`
            echo "${tgt}, ${tot_tgt}, ${tot_da}, ${ov_da}, ${tot_nda}, ${ov_nda}" >> $OUTPUT_FILE
          done


  '''
}

Counts_tables_Channel = Counts_tables_Channel.mix(Peaks_self_overlap_for_computing_pvalue)


// note: we need to save tmp files (overlap_DB.tmp and overlap_NDB.tmp, otherwise it crashes when there is zero overlap)

// note: here we use the option intersectBed -u instead of -wa to just indicate if at least one chip peak overlap with a given atac seq peak. Thus the number of overlap cannot be higher than the number of atac peaks.





DA_regions_with_bg_for_motifs_overlap
  // key (ET__PF__FC__FDR__COMP), DA_regions, all_regions
  .map{ [ "${it[0]}__motifs", "motifs", it[1], it[2] ] }
  .dump(tag:'peaks_for_homer')
  // format: key (ET__PF__FC__FDR__COMP__DT), data_type, DA_regions, all_regions
  .set{ DA_regions_with_bg_for_motifs_overlap1 }



process compute_motif_overlap {
  tag "${key}"

  container = params.homer

  publishDir path: "${out_processed}/3_Enrichment/${data_type}/${key}", mode: "${pub_mode}"

  input:
    set key, data_type, file(DA_regions), file(all_regions) from DA_regions_with_bg_for_motifs_overlap1

  output:
    file("**")
    set key, data_type, file("*__homer_results.txt") optional true into Know_motifs_for_reformatting

  when: params.do_motif_enrichment

  shell:
  '''


    findMotifsGenome.pl !{DA_regions} !{params.homer_genome} "."  -size given  -p !{params.nb_threads}  -bg !{all_regions}  -mknown !{params.pwms_motifs}  -nomotif


    FILE="knownResults.txt"
    if [ -f $FILE ]; then
       mv $FILE "!{key}__homer_results.txt"
    fi

  '''

}

// note: homer automatically removes overlapping peaks between input and bg, so it doesn't matter that we don't separtate them.



process reformat_motifs_results {
  tag "${key}"

  container = params.r_basic

  // publishDir path: "${out_processed}/3_Enrichment/${data_type}/2_dataframe/${key}", mode: "${pub_mode}"

  input:
    set key, data_type, file(motifs_results) from Know_motifs_for_reformatting

  output:
    set key, data_type, file("*__counts.csv") into Motifs_counts_for_computing_pvalue

  // when: params.do_chip_enrichment

  shell:
  '''
      #!/usr/bin/env Rscript

      library(magrittr)

      key = '!{key}'
      filename = '!{motifs_results}'


      df = read.csv(file = filename, sep = '\t', stringsAsFactors = F)

      total = purrr::map_chr(strsplit(names(df), 'Motif.of.')[c(6,8)], 2) %>% gsub('.', '', ., fixed = T) %>% as.integer

      names(df) = c('tgt', 'consensus', 'pvalue', 'log_pval', 'qval', 'ov_da', 'pt_da', 'ov_nda', 'pt_nda')
      df$tot_da  = total[1]
      df$tot_nda = total[2]
      df %<>% dplyr::select(tgt, tot_da, ov_da, tot_nda, ov_nda, consensus)
      wrong_entries = which(df$ov_nda > df$tot_nda)
      if(length(wrong_entries) > 0) { df$ov_nda[wrong_entries] = df$tot_nda[wrong_entries] }

      write.csv(df, paste0(key, '__motifs__counts.csv'), row.names = F)

  '''
}

Counts_tables_Channel = Counts_tables_Channel.mix(Motifs_counts_for_computing_pvalue)

// Counts_tables_Channel = Counts_tables_Channel.view()

// note : the "wrong_entries" command is used because ov_nda is sometimes slightly higher (by a decimal) than tot_nda; i.e.: tot_nda = 4374 and ov_nda = 4374.6. This makes the Fischer test crash later on. This change is minimal so we just fix it like that.

// This one liner works and is cleaner but it fails in nextflow due to the double escape string
// total = as.integer(stringr::str_extract_all(paste0(names(df), collapse = ' '),"\\(?[0-9]+\\)?")[[1]])



// need to add the key for this one: Genes_func_anno_count_for_computing_pvalue

// genes_self_overlap_for_computing_pvalue
//   .mix(peaks_self_overlap_for_computing_pvalue)
//   .mix(Genes_func_anno_count_for_computing_pvalue)
//   .mix(Motifs_counts_for_computing_pvalue)
//   // format: key (ET__PF__FC__FDR__COMP__DT), DT, csv_counts
//   // .map{ [ it.name.replaceFirst(~/__counts.csv/, ''), it ] }
//   // // format:  key (ET__PF__FC__FDR__COMP), csv_counts
//   .dump(tag: 'count_tables')
//   .set{ Counts_tables_Channel }
// Counts_tables_Channel = Counts_tables_Channel.mix(genes_self_overlap_for_computing_pvalue)


// Counts_tables_Channel = Counts_tables_Channel.dump(tag: 'counts_pval')

// the input to this process should be a df with these columns: tgt tot_da ov_da tot_nda ov_nda
// other extra columns are facultatory. These are: tot_tgt for bed_overlap, consensus for motifs, geneIds for ontologies/pathways

// data_types can be either of: func_anno(BP|CC|MF|KEGG), genes_self, peaks_self, chrom_states, CHIP, motifs

process compute_enrichment_pvalue {
  tag "${key}"

  container = params.r_basic

  input:
    set key, data_type, file(df_count_csv) from Counts_tables_Channel

  output:
    file("*.rds") into Enrichment_for_plot optional true
    set data_type, val("3_Enrichment"), file("*.rds") into Enrichment_for_formatting_table optional true

    // publishDir path: "${out_tab_indiv}/3_Enrichment/${data_type}", mode: "${pub_mode}", pattern = '*.csv', enabled: params.save_tables_as_csv

  // when: params.do_chip_enrichment

  shell:
  '''
        #!/usr/bin/env Rscript

        library(magrittr)
        source('!{projectDir}/bin/get_chrom_states_names_vec.R')

        key = '!{key}'
        data_type = '!{data_type}'
        df1 = read.csv('!{df_count_csv}', stringsAsFactors = F)
        motifs_test_type = '!{params.motifs_test_type}'



        # computing pvalue and L2OR
        df = df1
        for(c1 in 1:nrow(df)){
          ov_da   =   df$ov_da[c1]
          tot_da  =  df$tot_da[c1]
          ov_nda  =  df$ov_nda[c1]
          tot_nda = df$tot_nda[c1]
          mat = rbind(c(ov_da, ov_nda), c(tot_da - ov_da, tot_nda - ov_nda))
          fisher_test = fisher.test(mat, alternative = 'two.sided')
          df$pval[c1] = fisher_test$p.value
          df$L2OR[c1] = log2(fisher_test$estimate)
          if(data_type == 'motifs' & motifs_test_type == 'binomial') {
            df$pval[c1] = binom.test(ov_da, tot_da, ov_nda / tot_nda, alternative = 'two.sided')$p.value
          }
        }

        # adding padj and percentage of overlap
        df$padj = p.adjust(df$pval, method = 'BH')
        df %<>% dplyr::mutate(pt_da = ov_da  / tot_da  )
        df %<>% dplyr::mutate(pt_nda = ov_nda / tot_nda )
        df$pt_da %<>% {. * 100 } %>% round(2) %>% paste0(., '%')
        df$pt_nda %<>% {. * 100 } %>% round(2) %>% paste0(., '%')

        # renaming chromatin states
        if(data_type == 'chrom_states'){
          vec = get_chrom_states_names_vec()
          df$tgt %<>% vec[.]
        }

        # reordering columns
        df %<>% dplyr::select(tgt, pval, padj, L2OR, pt_da, ov_da, tot_da, pt_nda, ov_nda, tot_nda, dplyr::everything())

        # adding a Gene Enrichment Type column for func_anno
        if(grepl('func_anno', data_type)) {
          GE = gsub('func_anno_', '', data_type)
          data_type1 = 'func_anno'
        } else { data_type1 = data_type }

        # sorting by padj and then overlap counts
        df %<>% dplyr::arrange(padj, desc(ov_da))

        # adding the key and saving for plots
        key_split = strsplit(key, '__')[[1]]
        key_df = as.data.frame(t(key_split[-length(key_split)]), stringsAsFactors = F)
        cln = c('ET', 'PF', 'FC', 'FDR', 'COMP')
        key_df %<>% set_colnames(cln)
        if(data_type1 == 'func_anno') key_df %<>% cbind(GE = GE, .)
        df2 = cbind(key_df, df)
        saveRDS(df2, paste0(key, '__enrich.rds'))


  '''
}


Formatting_tables_Channel = Formatting_tables_Channel.mix(Enrichment_for_formatting_table)




////////////////////////////////////////////////////////////////////////////
// PLOTTING ENRICHMENT RESULTS


// note DT stands for Data_Type. It can be either 'genes_(BP|CC|MF|KEGG)', 'CHIP', 'motif' or 'chrom_states'
// comp_order has this format: Eri1Daf2_vs_Eri1|Eri1Eat2_vs_Eri1|Eri1Isp1_vs_Eri1|...

// Genes_ontologies_enrichment_for_plot
// .mix(Overlap_enrichment_for_plot)
// .mix(Know_motifs_for_plot)

Enrichment_for_plot
  // format: rds_file (key__enrich.rds)
  .flatten()
  // we need to flatten since the genes_sets
  .map{ [ it.name.replaceFirst(~/__enrich.rds/, ''), it ] }
  // format: key (ET__PF__FC__FDR__COMP__DT), rds_file
  .tap{ Enrich_results_for_barplot }
  .combine(comparisons_grouped_for_heatmap)
  // format: key, rds_file, GRP, comp_order
  .dump(tag:'enrichment')
  .map{ [ it[0].split('__')[4], it ].flatten() }
  // format: COMP, key, rds_file, GRP, comp_order
  .filter{ it[0] in it[4].split('\\|') }
  // keeping only COMP that are in the group
  .map{ [ it[1].split('__'), it[2..4] ].flatten() }
  // format: ET, PF, FC, FDR, COMP, DT, rds_file, GRP, comp_order
  .map{ [ it[0, 1, 3, 7, 5].join('__'), it[5, 8, 3, 6] ].flatten() }
  // format: key (ET__PF__FDR__GRP__DT), DT, comp_order, FDR, rds_file
  .groupTuple(by: [0, 1, 2, 3])
  // format: key, DT, comp_order, FDR, rds_files
  .filter{ it[4].size() > 1 }
  // .map{ it[0, 1, 2, 4] }
  .dump(tag:'heatmap')
  .set{ Enrich_results_for_heatmap }




Enrich_results_for_barplot
  // format: key (ET__PF__FC__FDR__COMP__DT), rds_file
  .map{ [ it[0], it[0].split('__')[5], it[1] ]  }
  // format: key (ET__PF__FC__FDR__COMP__DT), DT, rds_file
  .dump(tag: 'barplot')
  .set{ Enrich_results_for_barplot1 }



process plot_enrichment_barplot {
  tag "${key}"

  container = params.figures

  publishDir path: "${out_fig_indiv}/3_Enrichment/Barplots__${data_type}", mode: "${pub_mode}"

  input:
    set key, data_type, file(res_gene_set_enrichment_rds) from Enrich_results_for_barplot1

  output:
    // set val("2" + data_type + "_barplots"), val("Figures_Merged/3_Enrichment"), file("*.pdf") optional true into Barplot_for_merging_pdfs
    set val("Barplots__${data_type}"), val("3_Enrichment"), file("*.pdf") optional true into Barplot_for_merging_pdfs


  // when: params.do_gene_set_enrichment

  shell:
  '''

      #!/usr/bin/env Rscript

      library(ggplot2)
      library(grid)
      library(gridExtra)
      library(RColorBrewer)
      library(magrittr)

      key = '!{key}'
      data_type = '!{data_type}'
      df1 = readRDS('!{res_gene_set_enrichment_rds}')

      add_var_to_plot = '!{params.add_var_to_plot}'
      threshold_plot_adj_pval = !{params.threshold_plot_adj_pval}

      source('!{projectDir}/bin/get_new_name_by_unique_character.R')
      source('!{projectDir}/bin/functions_pvalue_plots.R')




      df = df1

      # quitting if there are no significant results to show
      if(all(df$padj > threshold_plot_adj_pval)) quit(save = 'no')

      # removing the genes_id column from func_anno enrichments (for easier debugging)
      df %<>% .[, names(.) != 'genes_id']

      # adding the loglog and binned padj columns
      if(grepl('func_anno', data_type)) data_type = 'func_anno'
      signed_padj = T
      df %<>% getting_padj_loglog_and_binned(data_type, signed_padj)

      # adding the yaxis terms column
      df$yaxis_terms = df$tgt

      # selecting lowest pvalues
      df$yaxis_terms %<>% substr(., 1, 50)
      df = df[!duplicated(df$yaxis_terms), ]
      df = df[seq_len(min(nrow(df), 30)), ]
      df$yaxis_terms %<>% factor(., levels = rev(.))

      is_bed_overlap = data_type %in% c('CHIP', 'chrom_states', 'peaks_self', 'genes_self')
      if(is_bed_overlap){
        xlab = paste0('Overlap (DA: ', df$tot_da[1], ', bg: ', df$tot_nda[1], ')')
      } else {
        xlab = paste0('Overlap (DA: ', df$tot_da[1], ')')
      }

      p1 = ggplot(df, aes(x = yaxis_terms, y = ov_da)) + coord_flip() + geom_bar(stat = 'identity') + ggtitle(key) + theme_bw() + theme(axis.title.y = element_blank(), axis.text = element_text(size = 11, color = 'black'), plot.title = element_text(hjust = 0.9, size = 10), legend.text = element_text(size = 7)) + ylab(xlab)

      point_size = scales::rescale(c(nrow(df), seq(0, 30, len = 5)), c(6, 3))[1]
      p_binned = get_plot_binned(p1, signed_padj, add_var_to_plot, point_size = point_size)

      pdf(paste0(key, '__barplot.pdf'), paper = 'a4r')
        print(p_binned)
      dev.off()


    '''
}

// # signed_padj = ifelse(data_type %in% c('CHIP', 'chrom_states'), T, F)

Merging_pdf_Channel = Merging_pdf_Channel.mix(Barplot_for_merging_pdfs.groupTuple(by: [0, 1]))




process plot_enrichment_heatmap {
  tag "${key}"

  container = params.figures

  publishDir path: "${out_fig_indiv}/3_Enrichment/Heatmaps__${data_type}", mode: "${pub_mode}"

  input:
    set key, data_type, comp_order, fdr, file('*') from Enrich_results_for_heatmap

  output:
    // set val("3" + data_type "_heatmaps_genes_sets"), val("Figures_Merged/3_Enrichment"), file("*.pdf") optional true into Heatmap_for_merging_pdfs
    set val("Heatmaps__${data_type}"), val("3_Enrichment"), file("*.pdf") optional true into Heatmap_for_merging_pdfs


  // when: params.do_motif_enrichment

  shell:
  '''
    #!/usr/bin/env Rscript


    library(magrittr)
    library(ggplot2)
    library(RColorBrewer)
    library(data.table)

    key        = '!{key}'
    comp_order = '!{comp_order}'
    data_type  = '!{data_type}'

    threshold_plot_adj_pval = !{params.threshold_plot_adj_pval}
    add_var_to_plot         = '!{params.add_var_to_plot}'
    up_down_pattern         = '!{params.up_down_pattern}'

    source('!{projectDir}/bin/get_new_name_by_unique_character.R')
    source('!{projectDir}/bin/get_chrom_states_names_vec.R')
    source('!{projectDir}/bin/functions_pvalue_plots.R')
    source('!{projectDir}/bin/functions_grouped_plot.R')




    # loading, merging and processing data
    rds_files = list.files(pattern = '*.rds')
    ldf = lapply(rds_files, readRDS)
    df = do.call(rbind, ldf)
    
    # filtering table
    if(data_type %in% c('genes_self', 'peaks_self')){
      key1 = paste(df[1, c('ET', 'PF', 'FDR')], collapse = '__')
      df$tgt_key = sapply(strsplit(df$tgt, '__'), function(x) paste(x[c(1,2,4)], collapse = '__'))
      df %<>% .[.$tgt_key %in% key1, ]
      df$tgt_key <- NULL
    }

    ## quitting if there are no significant results to show
    if(all(df$padj > threshold_plot_adj_pval)) quit(save = 'no')

    if(grepl('func_anno', data_type)) data_type = 'func_anno'

    # adding the comp_FC
    df$comp_FC = apply(df[, c('COMP', 'FC')], 1, paste, collapse = '_') %>% gsub('_vs_', '_', .)

    # ordering the x-axis comparisons
    comp_order_levels = get_comp_order_levels(comp_order, up_down_pattern)
    comp_order1 = comp_order_levels %>% .[. %in% unique(df$comp_FC)]

    # adding the yaxis terms column
    df$yaxis_terms = df$tgt

    # adding loglog and binned padj columns
    signed_padj = T
    df %<>% getting_padj_loglog_and_binned(data_type, signed_padj)

    # setting parameters for selection of yaxis terms to display
    if(data_type == 'func_anno'){
      nshared = 6 ; nunique = 20 ; ntotal = 26 ; threshold_type = 'fixed' ; threshold_value = 0.05 ; remove_similar = F
    }
    if(data_type %in% c('CHIP', 'motifs')){
      nshared = 8 ; nunique = 25 ; ntotal = 40 ; threshold_type = 'quantile' ; threshold_value = 0.25 ; seed = 38 ; remove_similar = T
    }

    add_number = F

    purrr__map_chr <- function(x, c1) lapply(x, function(y) y[c1]) %>% as.character

    # if plotting self overlap keeping only targets in the group
    if(data_type %in% c('genes_self', 'peaks_self')) {
      terms_levels = rev(comp_order1)
      strs = strsplit(df$tgt, '__')
      tgt_ET = purrr__map_chr(strs, 1)
      tgt_PF = purrr__map_chr(strs, 2)
      tgt_FC = purrr__map_chr(strs, 3)
      tgt_FDR = purrr__map_chr(strs, 4)
      tgt_COMP = purrr__map_chr(strs, 5)
      ET = unique(df$ET)
      PF = unique(df$PF)
      FDR = unique(df$FDR)
      df$tgt_comp_FC = paste0(tgt_COMP, '_', tgt_FC) %>% gsub('_vs_', '_', .)
      df = subset(df, tgt_comp_FC %in% comp_FC & tgt_ET == ET & tgt_PF == PF)
      df$yaxis_terms = df$tgt_comp_FC
      add_number = T
      add_var_to_plot = 'none'
    }

    # reformat df to a matrix
    mat_dt = dcast(as.data.table(df), yaxis_terms ~ comp_FC, value.var = 'padj_loglog', fill = get_pval_loglog(1))
    mat = as.matrix(mat_dt[,-1]) %>% set_rownames(mat_dt$yaxis_terms)

    # selecting and ordering the y-axis terms
    if(data_type %in% c('CHIP', 'motifs', 'func_anno')){
      terms_levels = select_y_axis_terms_grouped_plot(mat, nshared = nshared, nunique = nunique, ntotal = ntotal, threshold_type = threshold_type, threshold_value = threshold_value, remove_similar = remove_similar, remove_similar_n = 2, seed = 38)
    }
    if(data_type == 'chrom_states') {
      terms_levels = get_chrom_states_names_vec() %>% .[. %in% df$tgt] %>% unname  %>% rev
    }

    # clustering y-axis terms and adding final matrix indexes to the df
    mat_final = mat[terms_levels, comp_order1]
    rows = nrow(mat_final) ; cols = ncol(mat_final)
    df_final = add_matrix_indexes_to_df(mat_final, df, rows, cols, data_type, signed_padj)

    # getting and saving plots
    p1 = getting_heatmap_base(df_final, rows, cols, title = key, cur_mat = mat_final)
    point_size = scales::rescale(c(rows, seq(0, 40, len = 5)), c(3, 0.8))[1]
    p_binned = get_plot_binned(p1, signed_padj, add_var_to_plot, add_number, point_size = point_size)

    pdf(paste0(key, '__heatmap.pdf'))
      print(p_binned)
    dev.off()


  '''

}

// signed_padj = data_type %in% c('CHIP', 'chrom_states')

// Merging_pdf_Channel = Merging_pdf_Channel.mix(Heatmap_for_merging_pdfs.groupTuple(by: [0, 1]))
// Merging_pdf_Channel = Merging_pdf_Channel.mix(Heatmap_for_merging_pdfs.groupTuple(by: [0, 1]).map{ it.flatten() }.map{ [ it[0], it[1], it[2..it.size() - 1] ] })

Merging_pdf_Channel = Merging_pdf_Channel.mix(Heatmap_for_merging_pdfs.groupTuple(by: [0, 1])) //.dump(tag: 'test98')


// 
// signed_padj = F;  add_loglog = F; add_L2OR = F
// signed_padj = T;  add_loglog = T; add_L2OR = T
// 
// 
// ## Some explainations on the selection of terms to display (with the example of the algorithm for genes)
// # 26 terms at max will be plotted since it is the maximum to keep a readable plot
// # the first 6 slots will be attributed to terms that are the most shared amoung groups (if any term is shared)
// # then the top_N term for each group will be selected, aiming at 20 terms max
// # then the lowest pvalues overall will fill the rest of the terms (since shared terms will leave empty gaps)
// # Note that there should be at maximum 10 comparisons in each grouping plot (10 * 2 for up and down means at least 1 pvalue for each comparison)







////////////////////////////////////////////////////////////////////////////
// REFORMATING TABLES, MERGING TABLES AND PDFs





// this process allows to reformat tables as wished without breaking the cache

// Formatting_tables_Channel = Formatting_tables_Channel.dump(tag: 'format_tables')

process formatting_individual_tables {
  tag "${out_folder}__${data_type}"

  container = params.r_basic

  // publishDir path: "${out_tab_indiv}/3_Enrichment/${data_type}", mode: "${pub_mode}", pattern = '*.csv', enabled: params.save_tables_as_csv
  publishDir path: "${out_dir}/Tables_Individual/${out_folder}/${data_type}", mode: "${pub_mode}", enabled: params.save_tables_as_csv

  input:
    set data_type, out_folder, file(rds_file) from Formatting_tables_Channel
    // val out_path from Channel.value("Tables_Individual/${out_folder}/${data_type}")
    // set key, data_type, file(enrich_rds) from Formatting_tables_Channel
    // set data_type, merged_file_name, out_path, file(rds_file) from Formatting_tables_Channel
    // _for_formatting_


  output:
    set data_type, out_folder, file('*.csv') into Formatted_tables_for_merging optional true
    set val("Tables_Individual/${out_folder}/${data_type}"), file('*.csv') into Formatted_tables_for_Excel optional true

  // when: params.do_chip_enrichment

  shell:
  '''
        #!/usr/bin/env Rscript


        library(magrittr)
        source('!{projectDir}/bin/read_from_nextflow.R')
        source('!{projectDir}/bin/get_formatted_table.R')

        data_type = '!{data_type}'
        rds_file = '!{rds_file}'

        fdr_filter_tables       = read_from_nextflow('!{params.fdr_filter_tables}') %>% as.numeric
        fdr_filter_tables_names = read_from_nextflow('!{params.fdr_filter_tables_names}')


        # reading
        df = readRDS(rds_file)

        # filtering
        data_type1 = data_type
        if(grepl('func_anno', data_type)) data_type1 = 'func_anno'
        names(fdr_filter_tables) = fdr_filter_tables_names
        FDR_filter = fdr_filter_tables[data_type1]
        df = subset(df, padj <= FDR_filter)

        # formating
        df %<>% get_formatted_table

        # saving
        if(nrow(df) > 0) {
          output_file_name = paste0(gsub('.rds', '', rds_file), '.csv')
          write.csv(df, output_file_name, row.names = F)
        }


  '''
}

Exporting_to_Excel_Channel = Exporting_to_Excel_Channel.mix(Formatted_tables_for_Excel)


Formatted_tables_for_merging
  .groupTuple(by: [0, 1])
  .dump(tag: 'merge_tables')
  .set{ Formatted_tables_grouped_for_merging }

// Merging_tables_Channel = Merging_tables_Channel.mix(Formatted_tables_for_merging.groupTuple())
// Merging_tables_Channel = Merging_tables_Channel.dump(tag: 'merge_tables')

process formatting_merged_tables {
  tag "${out_folder}__${data_type}"

  container = params.r_basic

  publishDir path: "${out_dir}/Tables_Merged/${out_folder}", mode: "${pub_mode}", enabled: params.save_tables_as_csv

  input:
    set data_type, out_folder, file(csv_file) from Formatted_tables_grouped_for_merging

  output:
    set val("Tables_Merged/${out_folder}"), file("*.csv") into Merged_table_for_Excel optional true

  when: params.do_motif_enrichment

  shell:
  '''
      #!/usr/bin/env Rscript

      library(magrittr)
      library(dplyr)
      source('!{projectDir}/bin/get_formatted_table.R')

      data_type = '!{data_type}'


      # merging tables, 
      all_files = list.files(pattern = '*.csv')
      ldf = lapply(all_files, read.csv, stringsAsFactors = F, as.is = T)
      df = do.call(rbind, ldf)

      # formatting and saving merged table
      df %<>% get_formatted_table
      write.csv(df, paste0(data_type, '.csv'), row.names = F)


  '''
}

Exporting_to_Excel_Channel = Exporting_to_Excel_Channel.mix(Merged_table_for_Excel)



process save_excel_tables {
  tag "${csv_file}"

  // container = params.openxlsx => sh: : Permission denied ; Error: zipping up workbook failed. Please make sure Rtools is installed or a zip application is available to R.
  container = params.differential_abundance

  publishDir path: "${out_dir}/${out_path}", mode: "${pub_mode}", enabled: params.save_tables_as_excel

  input:
    set out_path, file(csv_file) from Exporting_to_Excel_Channel

  output:
    file("*.xlsx")

  when: params.do_motif_enrichment

  shell:
  '''
      #!/usr/bin/env Rscript

      library(openxlsx)

      csv_file = '!{csv_file}'
      excel_add_conditional_formatting = !{params.excel_add_conditional_formatting}
      excel_max_width = !{params.excel_max_width}


      options(digits = 1)

      df = read.csv(csv_file, stringsAsFactors = T, as.is = T)
      output_file_name = paste0(gsub('.csv', '', csv_file), '.xlsx')

      nms = names(df)

      class(df$pval) = 'scientific'
      class(df$padj) = 'scientific'

      if('pt_da' %in% nms){
        class(df$pt_da) = 'percentage'
        class(df$pt_nda) = 'percentage'
        L2OR_Inf_up   = which(df$L2OR == 'Inf')
        L2OR_Inf_down = which(df$L2OR == '-Inf')
        L2OR_not_Inf  = which(abs(df$L2OR) != 'Inf')
        df$L2OR[L2OR_Inf_up]   = 1e99
        df$L2OR[L2OR_Inf_down] = -1e99
      }

      names_colors  = c( 'filter',  'target',    'fold',  'pvalue',   'da',      'nda',    'other',    'gene', 'coordinate')
      # color type :       red        green     purple     orange     gold      pale_blue    grey     darkblue   darkolive
      header_colors = c('#963634', '#76933c', '#60497a', '#e26b0a', '#9d821f', '#31869b', '#808080', '#16365c',   '#494529'  )
      body_colors   = c('#f2dcdb', '#ebf1de', '#e4dfec', '#fde9d9', '#f1edcb', '#daeef3', '#f2f2f2', '#c5d9f1',   '#ddd9c4'  )
      names(header_colors) = names_colors
      names(body_colors)   = names_colors

      get_nms_type <- function(nms){
        nms_coordinates = c('chr','start', 'end',	'width', 'strand')
        nms_coordinates = c(nms_coordinates, paste0('gene_', nms_coordinates))

        if(nms %in% c('GE', 'ET', 'PF', 'FC', 'FDR', 'COMP')) return('filter') else
        if(nms %in% c('gene_name', 'gene_id', 'entrez_id'))   return('gene') else
        if(nms %in% c('pval', 'padj'))                        return('pvalue') else
        if(nms %in% c('L2FC', 'L2OR'))                        return('fold') else
        if(nms %in% c('tgt'))                                 return('target') else
        if(nms %in% c('pt_da', 'tot_da', 'ov_da'))            return('da') else
        if(nms %in% c('pt_nda', 'tot_nda', 'ov_nda'))         return('nda') else
        if(nms %in% nms_coordinates)                          return('coordinate') else
                                                              return('other')
      }
      nms_types = sapply(names(df), get_nms_type)
      nms_color_header = unname(header_colors[nms_types])
      nms_color_body   = unname(body_colors  [nms_types])

      sheet = 1
      cols = seq_len(ncol(df))
      rows = seq_len(nrow(df) + 1)

      # create the workbook
      wb = write.xlsx(df, output_file_name, borders = 'rows', keepNA = F)

      # add filter, set width and height
      addFilter(wb, sheet, 1, cols)
      setRowHeights(wb, sheet, 1, heights = 50)
      widths = apply(df, 2, function(x) {
        if(all(is.na(x))) return(5)
        width = max(nchar(x), na.rm = T) + 2.5
        width = ifelse(width > excel_max_width, excel_max_width, width)
        return(width)
      })
      setColWidths(wb, sheet, cols, widths = widths)

      for(col in cols) {
        col_nm = nms[col]
        halign = ifelse('GE' %in% nms & col_nm %in% c('tgt', 'genes_id'), 'left', 'center')
        header_style = createStyle(fontColour = '#ffffff', fgFill = nms_color_header[col], halign = halign, valign = 'center', textDecoration = 'Bold', border = 'TopBottomLeftRight', wrapText = T)
        addStyle(wb, sheet, header_style, rows = 1, col)

        body_style = createStyle(halign = halign, valign = 'center', fgFill = nms_color_body[col])
        addStyle(wb, sheet, body_style, rows = rows[-1], col)

        if(excel_add_conditional_formatting){
          if(col_nm == 'padj') conditionalFormatting(wb, sheet, cols = col, rows = rows[-1], type = 'colourScale', style = c('#e26b0a', '#fde9d9')) 
          vec = df[[col]]
          if(col_nm == 'L2FC') {
            conditionalFormatting(wb, sheet, cols = col, rows = rows[-1], type = 'colourScale', style = c(blue = '#6699ff', white = 'white', red = '#ff7c80'), rule = c(min(vec), 0, max(vec)))
          }
          if(col_nm == 'L2OR') {
            if(length(L2OR_not_Inf) > 0) {
              vec1 = vec[L2OR_not_Inf]
              vec1 = vec1[!is.na(vec1)]
              conditionalFormatting(wb, sheet, cols = col, rows = L2OR_not_Inf + 1, type = 'colourScale', style = c(blue = '#6699ff', white = 'white', red = '#ff7c80'), rule = c(min(vec1), 0, max(vec1)))
            }
            if(length(L2OR_Inf_up) > 0) addStyle(wb, sheet, createStyle(fgFill = c(lightblue = '#ff7c80'), halign = 'center', valign = 'center'), rows = L2OR_Inf_up + 1, col)
            if(length(L2OR_Inf_down) > 0) addStyle(wb, sheet, createStyle(fgFill = c(lightred = '#6699ff'), halign = 'center', valign = 'center'), rows = L2OR_Inf_down + 1, col)
          }
        }
      }

      # save the final workbook
      saveWorkbook(wb, output_file_name, overwrite = TRUE)


  '''
}

// documentation for openxlsx
// # https://www.rdocumentation.org/packages/openxlsx/versions/4.1.0.1
// # https://ycphs.github.io/openxlsx/articles/Introduction.html




// Merging_pdf_Channel = Merging_pdf_Channel.dump(tag: 'merging_pdf')

process merge_pdfs {
  tag "${file_name}"

  container = params.pdftk

  publishDir path: "${out_dir}/Figures_Merged/${out_path}", mode: "${pub_mode}"

  input:
    set file_name, out_path, file("*") from Merging_pdf_Channel

  output:
    file("*.pdf") optional true

  script:
  """

      pdftk `ls *pdf | sort` cat output ${file_name}.pdf

  """

}


////////////////////////////////////////////////////////////////////////////
// THE END MY FRIEND

// Merging_pdf_Channel.close()
// Formatting_tables_Channel.close()
// Counts_tables_Channel.close()



// on completion
 workflow.onComplete
 {
  println ""
  println "Workflow completed on: $workflow.complete"
  println "Execution status: ${ workflow.success ? 'Succeeded' : 'Failed' }"
  println "Workflow Duration: $workflow.duration"
  println ""
 }

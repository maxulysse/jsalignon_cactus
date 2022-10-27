
cd $cactus


examples_dir_pdf="docs/examples/pdf"
examples_dir_png="docs/examples/png"
examples_dir_html="docs/examples/html"

# volcano plot without removing specific regions
run_path="test_datasets/worm/results/test_worm__no_rtr/Figures_Individual"
cp $run_path/2_Differential_Abundance/ATAC__volcano/hmg4_vs_spt16__ATAC_volcano.pdf $examples_dir_pdf/hmg4_vs_spt16__ATAC_volcano__no_rtr.pdf 

run_path="test_datasets/worm/results/test_worm/Figures_Individual"
find $run_path -name "*ctl_1*.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "*hmg4_vs_ctl_*_volcano.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "*hmg4_vs_ctl_*_PCA_*.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "*hmg4_vs_ctl_*other_plots.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "spearman_correlation_heatmap_without_outliers_without_control_cor.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "ATAC__peaks__annotation_barplot.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "ATAC__peaks__average_profile.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "ATAC__peaks__distance_to_TSS.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "pca_top5000_without_control_pca.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "ATAC__multiQC.html" -exec cp "{}" $examples_dir_html \;
find $run_path -name "mRNA__multiQC.html" -exec cp "{}" $examples_dir_html \;
find $run_path -name "all__down__1000__hmg4_vs_ctl__venn_up_or_down.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "all__1000__hmg4_vs_ctl__venn_up_and_down.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "ATAC__all__down__1000__hmg4_vs_ctl__*.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "ATAC__all__down__1000__hmg4_vs_spt16__motifs__barplot.pdf" -exec cp "{}" $examples_dir_pdf \;
find $run_path -name "ATAC__all__1000__all__*.pdf" -exec cp "{}" $examples_dir_pdf \;



cd $examples_dir_pdf

# for FILE in $(ls *.pdf) 
# for FILE in $(ls *_volcano*.pdf) 
for FILE in $(ls ATAC__all__down__1000__hmg4_vs_spt16__motifs__barplot.pdf) 
do
  echo $FILE
  file_name=$(basename $FILE .pdf)
  pdftoppm -png -rx 300 -ry 300 $FILE > ${file_name}.png
done

mv *.png ../png
cd ../../..



## multiple files

cd $examples_dir_pdf

# for FILE in $(ls *.pdf) 
for FILE in $(ls *other_plots*.pdf) 
do
  echo $FILE
  file_name=$(basename $FILE .pdf)
  pdftoppm -png -rx 300 -ry 300 $FILE ${file_name}
done

mv *.png ../png
cd ../../..


FILE="ctl_1__reads_coverage.pdf"
file_name=$(basename $FILE .pdf)
pdftoppm -png -rx 300 -ry 300 $FILE > ${file_name}.png

mv *.png ../png

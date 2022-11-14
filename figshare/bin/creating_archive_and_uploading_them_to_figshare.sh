
# https://help.figshare.com/article/best-practice-for-managing-your-outputs-on-figshare

cactus_dir=/home/jersal/workspace/cactus
test_dir=$cactus_dir/test_datasets
refs_dir=$cactus_dir/references

cd $cactus_dir/figshare/files_to_upload


##############################################
### Creating archives
##############################################

n_cores=15

# references
tar --use-compress-program="pigz -p ${n_cores} -k -r" -cvf worm_refs.tar.gz $refs_dir/worm
tar --use-compress-program="pigz -p ${n_cores} -k -r" -cvf fly_refs.tar.gz $refs_dir/fly
tar --use-compress-program="pigz -p ${n_cores} -k -r" -cvf mouse_refs.tar.gz $refs_dir/mouse
tar --use-compress-program="pigz -p ${n_cores} -k -r" -cvf human_refs.tar.gz $refs_dir/human

# test datasets
tar --use-compress-program="pigz -p ${n_cores} -k -r" -cvf worm_test.tar.gz -C $test_dir/worm {data,design,parameters}
tar --use-compress-program="pigz -p ${n_cores} -k -r" -cvf fly_test.tar.gz -C $test_dir/fly {data,design,parameters}
# tar --use-compress-program="pigz -p ${n_cores} -k -r" -cvf mouse_test.tar.gz -C $test_dir/mouse {data,design,parameters}
tar --use-compress-program="pigz -p ${n_cores} -k -r" -cvf human_test.tar.gz -C $test_dir/human {data,design,parameters}

# adding the md5sum file
md5sum *.tar.gz > md5_sums.txt

# adding metadata files (README.txt)
cp ../metadata/* .


##############################################
### Uploading files to Figshare
##############################################

lftp -u "username,password=:bE~?" ftps.figshare.com 
set ftp:ssl-force true
set ftp:ssl-protect-data true
set ftp:passive-mode true
set ftp:auto-passive-mode true
set ftp:ssl-force on
set ftp:ssl-protect-data on
set ftp:passive-mode on
set ftp:auto-passive-mode on
set ssl:verify-certificate no
mkdir -p data/cactus
cd data/cactus

put worm_refs.tar.gz
put fly_refs.tar.gz
put mouse_refs.tar.gz
put human_refs.tar.gz

put worm_test.tar.gz
put fly_test.tar.gz
put mouse_test.tar.gz
put human_test.tar.gz

put README.txt
put manifest.txt

cat debug_log.txt 
# => this last commands allows to check if the put command worked. The upload often fail (i.e. " Incomplete upload, skipping..."). It needs to repeat it sometimes. It should be written: "started" and then on the line below "finished" for the upload to be successful.


##############################################
### Other information
##############################################

# my private link:
https://figshare.com/s/d943e9f8f7b014420b0a


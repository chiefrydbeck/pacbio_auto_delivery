#!/bin/bash
##30_make_Md5_htaccess_and_transfer.sh

##cmd line parameters
where_to_look_fore_deliv_instrux=$1
proj_dir_deliv_instrux=$2
working_dir=$3

##step into project directory for delivery instructions: Here one folder for each sampel should exist
echo "cd $path_parent_where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux"
cd $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux
shopt -s nullglob
arrOfFileNames=(*/)
echo "The samples are:"
printf '%s ' "${arrOfFileNames[@]}"
echo ""	

##Read project parameters
. $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux/project_parameters.sh
sequencer_lower=$( echo "$sequencer" | tr -s  '[:upper:]'  '[:lower:]' )
##Read sampel parameters
. $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux/${arrOfFileNames[0]}/sample_parameters.sh


echo "# Entering delivery folder"
echo cd ${working_dir}/../ProjFoldsForDeliv
cd ${working_dir}/../ProjFoldsForDeliv

##Make variable string content lower case
ln_usr_lower=$( echo "$ln_usr" | tr -s  '[:upper:]'  '[:lower:]' )

##Define project folder name
projectFolderName=Project\_$proj_dir_deliv_instrux\_$sampleType\_${sequencer_lower}
echo $projectFolderName

echo "#entering project folder for tar file"
echo "cd ${projectFolderName}"
cd ${projectFolderName}

##make md5sum file
echo "Making md5sum"
echo "md5sum *.tgz  > md5sum.txt"
echo ""
md5sum *.tgz  > md5sum.txt

##create .htaccess file
rm ./.htaccess
touch .htaccess
#echo "AuthUserFile /projects/NS9012K/www/hts-nonsecure.uio.no/Project_Ln_gdna_2017-06-12_sequel/${projectFolderName}/.htpasswd" >> .htaccess
echo "AuthUserFile /norstore_osl/home/timothyh/.htpasswd" >> .htaccess
echo "AuthGroupFile /dev/null" >> .htaccess
echo "AuthName ByPassword" >> .htaccess
echo "AuthType Basic" >> .htaccess
echo "" >> .htaccess
echo "<Limit GET>" >> .htaccess
echo "require user ${ln_usr_lower}-${sampleType}" >> .htaccess
echo "</Limit>" >> .htaccess

##create .htpasswd file
#echo htpasswd -bc .htpasswd ${ln_usr_lower}-${sampleType} ${sampleType}
#htpasswd -bc .htpasswd ${ln_usr_lower}-${sampleType} ${sampleType} 
##########################################SSH Norstore##########################################
ssh login.norstore.uio.no<<HERE
#Add the password to the password database file using the command below
htpasswd -b /norstore_osl/home/timothyh/.htpasswd ${ln_usr_lower}-${sampleType} ${sampleType}
HERE
####################################################################################
echo # Step up into Sequel_out_for_norstore_deliv folder
echo cd ..
echo ""
cd ..

echo "# Print tree"
echo tree "${projectFolderName}"
tree "${projectFolderName}"
echo ""

echo "# set permissions"
chmod 755 "${projectFolderName}"

echo "# Transferring project folder with tar and md5sum file to Norstore"
echo rsync -avp "${projectFolderName}" login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/
rsync -av "${projectFolderName}" login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/


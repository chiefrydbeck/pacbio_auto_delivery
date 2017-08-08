#!/bin/bash
##20_prepare_project_delivery_folder.sh 

##cmd line parameters
where_to_look_fore_deliv_instrux=$1
proj_dir_deliv_instrux=$2
working_dir=$3



##Read project parameters, external and internal samplename
. $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux/project_parameters.sh
sequencer_lower=$( echo "$sequencer" | tr -s  '[:upper:]'  '[:lower:]' )
echo "The projects folder for delivery instructions is: $proj_dir_deliv_instrux"
echo ""
echo "The project parameters (defined variables) are"
echo "sequencer=$sequencer"
echo "first name user=$fn_usr"
echo "last name user=$ln_usr"
echo "sampleType=$sampleType"
echo "deliveryRecipients=$deliveryRecipients"
echo ""

##step into project directory for delivery instructions: Here one folder for each sampel should exist
echo "cd $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux"
cd $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux
echo ""

##store names in array
shopt -s nullglob
arrOfFileNames=(*/)

##for every sample folder do 
for sampleFolderName in *; do
	if [ ${sampleFolderName} != "project_parameters.sh" ]; then
	echo "Creating symlink folder structure for sample: $sampleFolderName"	

	##Read sample parameters, external and internal samplename
	. $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux/${sampleFolderName}/sample_parameters.sh

	##Make variable string content lower case
	ln_usr_lower=$( echo "$ln_usr" | tr -s  '[:upper:]'  '[:lower:]' )

	##Define name of folder for project delivery
	projectDeliveryFolderName=Project\_$proj_dir_deliv_instrux\_$sampleType\_${sequencer_lower}

	echo "# Entering delivery folder, generic parent folder to project specific delivery folders"
	echo cd ${working_dir}/../ProjFoldsForDeliv
	cd ${working_dir}/../ProjFoldsForDeliv

	##remove any preexisting project folder for symlinks
	#rm -rf "${projectDeliveryFolderName}_symlinks" #not a good thing if there are many samples per project

	##create project folder for symlinks
	echo "# Creating and entering project folder to collect symlinks"
	echo mkdir -p "${projectDeliveryFolderName}_symlinks"
	mkdir -p "${projectDeliveryFolderName}_symlinks"

	##enter project folder for symlinks
	echo cd "${projectDeliveryFolderName}_symlinks"
	cd "${projectDeliveryFolderName}_symlinks"

	##remove any preexisisting  folder for symlinks with externalSampleName
	rm -rf ${extSampleName}

	##Create and enter folder for symlinks named with externalSampleName
	echo "# Creating folder with external sample name"
	echo mkdir -p ${extSampleName}
	mkdir -p ${extSampleName}

	##enter symlinks folder named with externalSampleName
	echo cd ${extSampleName}
	echo " "
	cd ${extSampleName}

	echo "# Creating a parent folder, with run name  as name, with symlinks to SMRTcells as  subfolders"
	echo "# Reading SMRTcell fies from: $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux/$sampleFolderName/SMRTcells.txt"
	while read file1; do
		echo "File is: $file1"
		if [ -n "$file1" ]; then
		##remove the last character, in case its a slash
			file2="${file1%?}"
		##count number of occurrences of slash in file2
			number_of_occurrences=$(grep -o "/" <<< "$file2" | wc -l)
		##select name of SMRTcell parent folder
			runFolder=$(echo $file1| cut -d'/' -f $number_of_occurrences)
			smrtCell=$(echo $file1| cut -d'/' -f $((number_of_occurrences+1)))
		echo "##############run:"${runFolder}" smrtcell: "${smrtCell}"###############"
	
		echo mkdir $runFolder
		mkdir $runFolder
		echo cd $runFolder
		cd $runFolder
		echo ""
		echo "We are now in:"
		pwd

		echo "Making symlink with:"
		echo "eval ln\ -s\ \$file2 \${smrtCell}"
		eval ln\ -s\ \$file2 \${smrtCell}

		echo cd ..
		cd ..
		echo "We are now in run folder:"
		pwd
		echo ""
	
		echo " "
		fi
	done < $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux/$sampleFolderName/SMRTcells.txt
fi
done

echo "############## Done with symlinks ###############"
echo ""

echo "# Entering delivery folder, generic parent folder to project specific delivery folders"
echo cd ${working_dir}/../ProjFoldsForDeliv
cd ${working_dir}/../ProjFoldsForDeliv


echo "# A folder structure has now been created..."
echo tree "${projectDeliveryFolderName}_symlinks"
tree "${projectDeliveryFolderName}_symlinks" 
echo ""
echo "# ...lets make a tarball of it and md5sum it,..."
echo ""

##create project folder for tar file
echo "#...in a folder with the project folder name"
echo mkdir -p "${projectDeliveryFolderName}"
mkdir -p "${projectDeliveryFolderName}"

##enter project folder for tar file
echo cd "${projectDeliveryFolderName}"
echo ""
cd "${projectDeliveryFolderName}"

echo "We are now in:"
pwd
#${sampleFolderName%/}
##for every sample folder do 
for sampleFolderName in "${arrOfFileNames[@]}"; do
	echo "# Creating tarball with data for ${sequencer}"
	if [ "$sequencer" = "RSII" ]
		then
		echo "RSII"
		echo 'find -L ../${projectDeliveryFolderName}"_symlinks"/${sampleFolderName} -iname "*.metadata.xml" -o -name "*.subreads.fastq" -o -name "*.bax.h5" | tar -h -czvf $sampleFolderName.tgz -T -'
#		echo \''find -L ../${projectDeliveryFolderName}'_symlinks'/${sampleFolderName} -iname '*.metadata.xml' -o -name '*.subreads.fastq' -o -name '*.bax.h5' | tar -h -czvf $sampleFolderName.tgz -T -'\' 
#		cat <<'EOF'
#		find -L ../${projectDeliveryFolderName}"_symlinks"/${sampleFolderName} -iname "*.metadata.xml" -o -name "*.subreads.fastq" -o -name "*.bax.h5" | tar -h -czvf ${sampleFolderName%/}.tgz -T -
#		EOF
		find -L ${working_dir}/../ProjFoldsForDeliv/${projectDeliveryFolderName}"_symlinks"/${sampleFolderName} -iname "*.metadata.xml" -o -name "*.subreads.fastq" -o -name "*.bax.h5" | tar -h -czvf ${sampleFolderName%/}.tgz -T -
	elif [ "$sequencer" = "Sequel" ]
		then
		echo "Sequel"
		echo 'find -L ../${projectDeliveryFolderName}"_symlinks"/${sampleFolderName} -iname "*.fasta" -o -name "*.bam" -o -name "*.pbi" -o -name "*.xml" -o -name "*.fastq" | tar -h -czvf $sampleFolderName.tar -T -'
		echo ""
		#Compression is used here since delivery data contains fastq files in addition to the bam (binary/compressed) files
		find -L ${working_dir}/../ProjFoldsForDeliv/${projectDeliveryFolderName}"_symlinks"/${sampleFolderName} -iname "*.fasta" -o -name "*.bam" -o -name "*.pbi" -o -name "*.xml"  -o -name "*.fastq" | tar -h -czvf ${sampleFolderName%/}.tgz -T -
		echo ""
	else
		echo "The sequencer specified is not recognised"
	fi
done

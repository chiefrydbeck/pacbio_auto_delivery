#!/bin/bash

##Example:
# deliver sequel
#sh deliver_pacbio.sh 02_test_sequel_2017_08_01_fn_ln trans                 
#RSII
#sh deliver_pacbio.sh 01_test_rsii_2017_06_25_fn_ln trans

##Hard set path to working directory
working_dir=$(pwd)
##Hard set path to directory where scripts should be looking for project and sample delivery instruction folders 
where_to_look_fore_deliv_instrux="$working_dir/../DelivInstrucs"

##Set name of folder with instructions for this sample
project_deliv_instrux_folder=$1
md5_trans_email=$2

##Read project parameters, external and internal samplename
. $where_to_look_fore_deliv_instrux/$project_deliv_instrux_folder/project_parameters.sh

echo ""
echo "The project parameters (defined variables) are"
echo "sequencer=$sequencer"
echo "first name user=$fn_usr"
echo "last name user=$ln_usr"
echo "sampleType=$sampleType"
echo "deliveryRecipients=$deliveryRecipients"
echo ""

sequencer_lower=$( echo "$1" | tr -s  '[:upper:]'  '[:lower:]' )
echo sequel_deliver.sh at 
pwd
echo ""
echo "where_to_look_fore_deliv_instrux is hard set in script to $where_to_look_fore_deliv_instrux"
echo "Called with parameter for project_deliv_instrux_folder which was  $1"
echo ""

if [ "$sequencer" = "Sequel" ]; then
	echo "Delivering Sequel data"
	echo ""
	##Call bam2fastq script
	echo "########################################################################### - Calling 10_convertSequelBam2Fastq.sh - #######################################################################################"
	echo ""
	echo sh /work/projects/nscdata/PacbioAutomation/PacbioAutoScript/shell/10_convertSequelBam2Fastq.sh ${where_to_look_fore_deliv_instrux} ${project_deliv_instrux_folder}
	sh $working_dir/../PacbioAutoScript/shell/10_convertSequelBam2Fastq.sh ${where_to_look_fore_deliv_instrux} ${project_deliv_instrux_folder} $working_dir
	echo ""

	##Check that fast file has been generated
	echo "Check that fastq file has been generated"
	echo ""
	cd ${where_to_look_fore_deliv_instrux}/${project_deliv_instrux_folder}
	for sampleFolderName in *; do
		echo "Checking ${sampleFolderName}"
		cat ${where_to_look_fore_deliv_instrux}${project_deliv_instrux_folder}/${sampleFolderName}/SMRTcells.txt | xargs ls
		echo ""
	done
elif [ "$sequencer" = "RSII" ]; then
	echo "Delivering RSII data"
else
	echo "Do not recognise specified sequencer. It should be specified as first parameter as Sequel or RSII."
fi

##Call delivery script
echo "########################################################################### - Calling 20_prepare_project_delivery_folder.sh - #######################################################################################"
echo ""
echo "sh /work/projects/nscdata/PacbioAutomation/PacbioAutoScript/shell/20_prepare_project_delivery_folder.sh ${where_to_look_fore_deliv_instrux} ${project_deliv_instrux_folder} | tee 1> /work/projects/nscdata/PacbioAutomation/AutomationRun/deliv_${project_deliv_instrux_folder}.out 2> /work/projects/nscdata/PacbioAutomation/AutomationRun/deliv_${project_deliv_instrux_folder}_1.err"
sh $working_dir/../PacbioAutoScript/shell/20_prepare_project_delivery_folder.sh ${where_to_look_fore_deliv_instrux} ${project_deliv_instrux_folder} $working_dir
echo ""

if [ "$md5_trans_email" = "trans" ]; then

	##Call make md5 and htaccess script?
	echo "########################################################################### - Calling 30_make_Md5_htaccess_and_transfer.sh - #######################################################################################"
	echo ""
	echo "sh /work/projects/nscdata/PacbioAutomation/PacbioAutoScript/shell/30_make_Md5_htaccess_and_transfer.sh ${where_to_look_fore_deliv_instrux} ${project_deliv_instrux_folder}"
	sh $working_dir/../PacbioAutoScript/shell/30_make_Md5_htaccess_and_transfer.sh ${where_to_look_fore_deliv_instrux} ${project_deliv_instrux_folder} $working_dir
	echo ""

	##Call script to send delivery email template
	echo "########################################################################### - Calling 40_sendDeliveryEmailTemplate.sh - #######################################################################################"

	echo ""
	echo "sh /work/projects/nscdata/PacbioAutomation/PacbioAutoScript/shell/40_sendDeliveryEmailTemplate.sh ${where_to_look_fore_deliv_instrux} ${project_deliv_instrux_folder}"
	sh $working_dir/../PacbioAutoScript/shell/40_sendDeliveryEmailTemplate.sh ${where_to_look_fore_deliv_instrux} ${project_deliv_instrux_folder} $working_dir
else
	echo "Not calling 30_make_Md5_htaccess_and_transfer.sh and 40_sendDeliveryEmailTemplate.s. Need second parameter to be "trans" for this to happen."
fi

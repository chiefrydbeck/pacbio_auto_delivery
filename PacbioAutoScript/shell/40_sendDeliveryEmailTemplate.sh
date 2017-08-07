#!/bin/bash

##40_sendDeliveryEmailTemplate.sh

#cmd line parameters
where_to_look_for_deliv_instrux=$1
proj_dir_deliv_instrux=$2

##Read project parameters, external and internal samplename
. $where_to_look_for_deliv_instrux/$proj_dir_deliv_instrux/project_parameters.sh
sequencer_lower=$( echo "$sequencer" | tr -s  '[:upper:]'  '[:lower:]' )

##Collect sample folder names
echo "cd $where_to_look_for_deliv_instrux/$proj_dir_deliv_instrux"
cd $where_to_look_for_deliv_instrux/$proj_dir_deliv_instrux
shopt -s nullglob
arrOfFileNames=(*/)
echo "The samples are:"
printf '%s ' "${arrOfFileNames[@]}"
echo ""	
##Read parForShell.sh
. $where_to_look_for_deliv_instrux/$proj_dir_deliv_instrux/${arrOfFileNames[0]}/sample_parameters.sh

##Specify email recipient
emailRecipients=${USER}@ibv.uio.no

#Create password for delivery folder
#pw=$(tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | fold -w 12 | head -n 1)

##Define project folder name
projectDeliveryFolder=Project\_$proj_dir_deliv_instrux\_$sampleType\_${sequencer_lower}

#Make lastname variable lower case
#echo "$ln_usr"
ln_usr_lower=$( echo "$ln_usr" | tr -s  '[:upper:]'  '[:lower:]' )

cat > /work/projects/nscdata/PacbioAutomation/Sequel_out_for_norstore_deliv/emails/${projectDeliveryFolder}DeliveryEmail.txt << EOF1

Hej ${USER},

The project $projectDeliveryFolder is now uploaded to Norstore:

The delivery email should be sent to: ${deliveryRecipients}

On Norstore do, htpasswd /norstore_osl/home/timothyh/.htpasswd ${ln_usr_lower}-${sampleType} and enter pwd.

Dear $fn_usr,

The above samples have been sequenced and the sequence data as well as the raw output data are now ready for pick-up.

----- Delivery method ------
You can download data from NSC ftp site by applying the following information:

https://webserver1.norstore.uio.no/${projectDeliveryFolder}

username: ${ln_usr_lower}-${sampleType}
password: ${sampleType}

An md5sum.txt file is included in the result folder. Please refer to our website (http://www.sequencing.uio.no/services/data-delivery/) for help on how to download the data and on how to use the md5sum.txt file to check whether the files are downloaded completely. 


------ Understanding the data ------
Please refer to our website (http://www.sequencing.uio.no/services/data-delivery/) for a detailed explanation of file contents and formats. This web page contains a lot of information that is essential to understanding your sequence data, so please read it. However, we would like to particularly emphasize one very IMPORTANT point: the sequence files are in Sanger fastq format (see http://en.wikipedia.org/wiki/FASTQ_format).


------- Acknowledgement -------
The Norwegian Sequencing Centre (NSC) operates as a core facility and you will therefore not be billed for the labour costs incurred. However, you are requested to acknowledge the support you have received from the bodies funding the NSC. Please use the following text in articles or reports relating to this sequence data:
"The sequencing service was provided by the Norwegian Sequencing Centre (www.sequencing.uio.no), a national technology platform hosted by the University of Oslo and supported by the "Functional Genomics" and "Infrastructure" programs of the Research Council of Norway and the Southeastern Regional Health Authorities".


----- Conclusion ------
Please let us know how you get on with the above. It is not unlikely that you experience some problem (or have a question), in which case don't hesitate to get in touch. Hopefully, however, everything is fine and you are able to download, access and understand your data, in which case we also value your feedback.


Best regards,

Halfdan Rydbeck

EOF1

echo "About to send email"
echo "cat /work/projects/nscdata/PacbioAutomation/Sequel_out_for_norstore_deliv/emails/${projectDeliveryFolder}DeliveryEmail.txt | \
mailx -s "Sequence ready for download - ${projectDeliveryFolder} - sample ${arrOfFileNames[@]}" $emailRecipients"
cat /work/projects/nscdata/PacbioAutomation/Sequel_out_for_norstore_deliv/emails/${projectDeliveryFolder}DeliveryEmail.txt | \
mailx -s "Sequence ready for download - ${projectDeliveryFolder} - sample ${arrOfFileNames[@]}" $emailRecipients
#rm /work/projects/nscdata/PacbioAutomation/Sequel_out_for_norstore_deliv/emails/${projectDeliveryFolder}DeliveryEmail.txt


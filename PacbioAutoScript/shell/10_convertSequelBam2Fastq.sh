#10_convertSequelBam2Fastq.sh
#Convert sequel bam to fastq
##load smrtlink module 
module load smrtlink

##
where_to_look_fore_deliv_instrux=$1
proj_dir_deliv_instrux=$2

##step into project delivery instruction folder
cd $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux

## for every sampel folder
for sampleFolderName in *; do
	if [ ${sampleFolderName} != "project_parameters.sh" ]; then
		##convert to bam	
		echo "Converting bam to fastq for $sampleFolderName"
		while read smrtCellPath; do
			if [ -n "$smrtCellPath" ]; then
				number_of_occurrences=$(grep -o "/" <<< "$smrtCellPath" | wc -l)
				#echo "smrtCell=$(echo $smrtCellPath| cut -d'/' -f $(number_of_occurrences))"
				smrtCell=$(echo $smrtCellPath| cut -d'/' -f $number_of_occurrences)
				runFolder=$(echo $smrtCellPath| cut -d'/' -f $((number_of_occurrences-1)))
				rAnds=$runFolder"/"$smrtCell"/"
				inputPath=${smrtCellPath%${rAnds}}
				echo "##############run:"${runFolder}" smrtcell: "${smrtCell}"###############"
				echo "Converting bam to fastq in :" ${smrtCellPath}
				cd $smrtCellPath
				for bamFile in *.bam
					do
					fn_no_ext="${bamFile%.*}"
					echo bamtools convert -format fastq -in $fn_no_ext.bam -out $fn_no_ext.fastq
					bamtools convert -format fastq -in $fn_no_ext.bam -out $fn_no_ext.fastq
				done
				echo " "
			fi
		done < $where_to_look_fore_deliv_instrux/$proj_dir_deliv_instrux/$sampleFolderName/SMRTcells.txt
		echo ""
	fi
done

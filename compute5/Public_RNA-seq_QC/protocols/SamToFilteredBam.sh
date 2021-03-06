#MOLGENIS nodes=1 ppn=1 mem=8gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string referenceGenomeHisat
#string reads1FqGz
#string reads2FqGz
#string platform
#string alignmentDir
#string uniqueID
#string samtoolsVersion
#string filteredBamDir
#string unfilteredBamDir
#string filteredBam


#Load modules
${stage} SAMtools/${samtoolsVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

mkdir -p ${filteredBamDir}
mkdir -p ${unfilteredBamDir}

if [[ ! -f ${alignmentDir}/${uniqueID}.sam ]]
then
   echo "${alignmentDir}/${uniqueID}.sam does not exist"
   exit 1
fi
# delete lines that contain NH:i:<not 1>, then convert sam to bam. See https://ccb.jhu.edu/software/hisat/manual.shtml, sam output
# NH:i:<N>	The number of mapped locations for the read or the pair. 
if sed '/NH:i:[^1]/d' ${alignmentDir}/${uniqueID}.sam | samtools view -h -b - > ${filteredBam}
then
   samtools view -h -b ${alignmentDir}/${uniqueID}.sam > ${unfilteredBamDir}/${uniqueID}.bam
  >&2 echo "Reads with flag NH:i:[2+] where filtered out (only leaving 'unique' mapping reads)."
  rm ${alignmentDir}/${uniqueID}.sam
  echo "returncode: $?";
  cd ${unfilteredBamDir}
  md5sum $(basename ${unfilteredBamDir}/${uniqueID}.bam)> $(basename ${unfilteredBamDir}/${uniqueID}.bam).md5
  cd -
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

if [ ! -f ${unfilteredBamDir}/${uniqueID}.bam ]; then
    echo "${unfilteredBamDir}/${uniqueID}.bam"
    exit 1
fi

echo "## "$(date)" ##  $0 Done "

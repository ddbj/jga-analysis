#!/bin/bash

# echo "-----"
# echo "ALL ARGS [$@]"

INPUTFILESDIR=${@:$#:1}
# echo "---- list INPUTFILESDIR"
# ls -l ${INPUTFILESDIR}
# echo "---- list INPUTFILESDIR/*.g.vcf.gz"
# ls -l ${INPUTFILESDIR}/*.g.vcf.gz

GLOBPATTERN=*.g.vcf.gz
for I in "${@}"; do
  if  [[ ${I} == *.bed ]]
  then
    if [[ ${I} == *chrX_nonPAR_ploidy_1* ]]
    then
      GLOBPATTERN=*.chrX_nonPAR_ploidy_1.g.vcf.gz
    elif [[ ${I} == *chrY_nonPAR_ploidy_1* ]]
    then
      GLOBPATTERN=*.chrY_nonPAR_ploidy_1.g.vcf.gz
    fi
  fi
done

INPUTFILEOPTIONS=""
for FILE in $(ls ${INPUTFILESDIR}/${GLOBPATTERN})
do
  INPUTFILEOPTIONS+=" -V ${FILE}"
done

#echo "---- command to be executed"

/usr/bin/java  ${@:1:($#-1)} ${INPUTFILEOPTIONS}

#ls -l /
#echo $INPUTFILEOPTIONS


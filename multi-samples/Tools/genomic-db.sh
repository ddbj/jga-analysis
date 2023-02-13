#!/bin/bash

# echo "-----"
# echo "ALL ARGS [$@]"

INPUTFILESDIR=${@:$#:1}
# echo "---- list INPUTFILESDIR"
# ls -l ${INPUTFILESDIR}
# echo "---- list INPUTFILESDIR/*.g.vcf.gz"
# ls -l ${INPUTFILESDIR}/*.g.vcf.gz
INPUTFILEOPTIONS=""
for FILE in $(ls ${INPUTFILESDIR}/*.g.vcf.gz)
do
  INPUTFILEOPTIONS+=" -V ${FILE}"
done

#echo "---- command to be executed"

/usr/bin/java  ${@:1:($#-1)} ${INPUTFILEOPTIONS}

#ls -l /
#echo $INPUTFILEOPTIONS

#!/bin/bash

CROMWELL_VERSION=88
CROMWELL_JAR_URI=https://github.com/broadinstitute/cromwell/releases/download/${CROMWELL_VERSION}/cromwell-${CROMWELL_VERSION}.jar
DIR="$(dirname "$0")"
CROMWELL_JAR_LOCAL=${DIR}/cromwell-${CROMWELL_VERSION}.jar

if [ ! -f ${CROMWELL_JAR_LOCAL} ]; then
   curl ${CROMWELL_JAR_URI} -o ${CROMWELL_JAR_LOCAL} -L
fi

java -Xmx32g \
     -XX:ActiveProcessorCount=16 \
     -Dconfig.file=${DIR}/nig-pg.conf \
     -jar ${CROMWELL_JAR_LOCAL} \
     server

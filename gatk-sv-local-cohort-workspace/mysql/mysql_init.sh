#!/bin/bash

source mysql_params.sh

mkdir -p ${MYSQL_DATA_DIR}/mysql/var/lib/mysql ${MYSQL_DATA_DIR}/mysql/run/mysqld

IMAGE_PATH=${PWD}/mysql_${MYSQL_VERSION}.sif

if [ ! -f ${IMAGE_PATH} ]; then
   apptainer pull docker://mysql:${MYSQL_VERSION}
fi

sed "s|<MYSQL_ROOT_PASSWORD>|${MYSQL_ROOT_PASSWORD}|" init.sql.template > init.sql
sed "s|<IMAGE_PATH>|${IMAGE_PATH}|" mysql_start.sh.template > mysql_start.sh
chmod u+x mysql_start.sh
sed "s|<MYSQL_ROOT_PASSWORD>|${MYSQL_ROOT_PASSWORD}|" .my.cnf.template | sed "s|<MYSQL_PORT>|${MYSQL_PORT}|" > ${HOME}/.my.cnf

apptainer instance start \
    --bind ${HOME} \
    --bind ${PWD} \
    --bind ${MYSQL_DATA_DIR}/mysql/var/lib/mysql/:/var/lib/mysql \
    --bind ${MYSQL_DATA_DIR}/mysql/run/mysqld:/run/mysqld \
    ${IMAGE_PATH} mysql
apptainer exec instance://mysql mysqld --initialize --init-file=${PWD}/init.sql
apptainer instance stop mysql

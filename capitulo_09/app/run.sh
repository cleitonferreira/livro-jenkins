#!/bin/bash
# Iniciando o microsservico no Ubuntu

#------------------
# VARIAVEIS
#------------------
BRANCH_CONFIG=$1
ENABLE_DEBUG=$2
NAME_ENVIRONMENT=$3
MEMORY_JVM=$4
BRANCH_CONFIG=${BRANCH_CONFIG:-master}
ENABLE_DEBUG=${ENABLE_DEBUG:-false}
NAME_ENVIRONMENT=${NAME_ENVIRONMENT:-prod}
MEMORY_JVM=${MEMORY_JVM:-512}

SERVICE_DIR_BASE=/home/livro/
SERVICE_DIR=$SERVICE_DIR_BASE/app
SERVICE_APP_FILE=applivro.jar
LOGFILE=$SERVICE_DIR_BASE/log/applivro.log
ADMIN_USER=livro

#------------------
# MAIN
#------------------

chown -R $ADMIN_USER:livro $SERVICE_DIR_BASE/
chmod -R 755 $SERVICE_DIR_BASE/

cd $SERVICE_DIR/
ln -sf application-$NAME_ENVIRONMENT.properties application.properties

if "$ENABLE_DEBUG" == "false" ; then
  /bin/su -c "/usr/bin/java \
              -Xmx${MEMORY_JVM}m \
              -jar $SERVICE_DIR/$SERVICE_APP_FILE --logging.file=$LOGFILE --spring.profiles.active=$NAME_ENVIRONMENT " $ADMIN_USER
else
  /bin/su -c "/usr/bin/java \
              -Xmx${MEMORY_JVM}m \
              -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5005,suspend=n \
              -jar $SERVICE_DIR/$SERVICE_APP_FILE --logging.file=$LOGFILE --spring.profiles.active=$NAME_ENVIRONMENT " $ADMIN_USER
fi

cd -

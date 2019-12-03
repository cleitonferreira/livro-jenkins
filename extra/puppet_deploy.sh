#!/bin/bash
#
#-------------------------------------------------------
# file: puppet_deploy.sh
# version: 1.0
# comment: Script de integracao do Jenkins e o Puppet-Bolt para deploy
# authors: Aecio Pires <aeciopires@gmail.com>,
# date: 11-ago-2018
# revision: Aecio Pires <aeciopires@gmail.com>
# last updated: 11-Ago-2018, 16:25
#-------------------------------------------------------

DEPLOY_ENV=$1
LOGIN=$2
PASS=$3
HOSTFILE=$4
PROJECT=$5
NAME_DOCKER_IMAGE=$6
LOGTEMP="/tmp/jenkins-deploy-$DEPLOY_ENV-$PROJECT-.txt"
BOLT='/opt/puppetlabs/bin/bolt'

# Integracao Puppet-Bolt + Jenkins
# Instale o Puppet Bolt seguindo as instrucoes da pagina:
# https://puppet.com/docs/bolt/latest/bolt_installing.html

# Executando o deploy usando o Puppet-Bolt
$BOLT command run "docker pull $NAME_DOCKER_IMAGE; \
  docker rm -f applivro; \
  docker run -d -p 8080:8080 --name applivro --restart=always $NAME_DOCKER_IMAGE" \
  -u $LOGIN -p $PASS \
  --node @$HOSTFILE \
  --no-host-key-check --verbose \
  --debug > $LOGTEMP

exit 0

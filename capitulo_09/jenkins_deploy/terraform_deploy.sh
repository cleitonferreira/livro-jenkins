#!/bin/bash
#
#-------------------------------------------------------
# file: terraform_deploy.sh
# version: 1.0
# comment: Script de integracao do Jenkins e o Terraform para deploy
# authors: Aecio Pires <aeciopires@gmail.com>,
# date: 11-ago-2018
# revision: Aecio Pires <aeciopires@gmail.com>
# last updated: 11-Ago-2018, 16:25
#-------------------------------------------------------
DIR=$(dirname $0)
DEPLOY_ENV=$1
PROJECT=$2
NAME_DOCKER_IMAGE=$3
TERRAFORM_VERSION="0.11.10"
TERRAFORM_PLATAFORM="_linux_amd64"
TERRAFORM_PACKAGE="terraform_$TERRAFORM_VERSION$TERRAFORM_PLATAFORM.zip"
TERRAFORM_DOWNLOAD_URL="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/$TERRAFORM_PACKAGE"
TERRAFORM_BIN="terraform"
TERRAFORM="/tmp/$TERRAFORM_BIN"
TERRAFORM_APP_DIR="terraform-docker-app"
LOGTEMP="/tmp/jenkins-deploy-$DEPLOY_ENV-$PROJECT-.txt"

#------------
# MAIN
#------------

if [ ! -f $TERRAFORM ]; then
  # Instalando dependencias e o terraform
  apt-get install -y unzip wget > /dev/null 2>&1
  cd /tmp
  wget $TERRAFORM_DOWNLOAD_URL -O /tmp/$TERRAFORM_PACKAGE
  unzip $TERRAFORM_PACKAGE
  chmod +x $TERRAFORM
fi

# Executando o deploy usando o Terraform + Docker
cd $DIR
$TERRAFORM init $TERRAFORM_APP_DIR
$TERRAFORM destroy -auto-approve $TERRAFORM_APP_DIR
$TERRAFORM apply -auto-approve $TERRAFORM_APP_DIR
#$TERRAFORM show $TERRAFORM_APP_DIR

exit 0

# [![ERPNext](https://erpnext.com/files/erpnext-logo-blue-v2.png)](https://erpnext.com/)


# Modello di deployment

Questo repository contiene gli artefatti necessari per il deployment dell'applicazione ERPNext su un cluster Google Kubernetes Engine. I dati vengono persistiti su un Maria DB e su un NFS share basato su Filestore.

Il diagramma di deployment  delle componenti applicative e' il seguente:

![](https://github.com/italia/cloud-google-erpnext/blob/main/images/deployment.png)



[![license](https://img.shields.io/badge/License-AGPL%20v3-blue.svg?logo=gnu&style=for-the-badge)](https://github.com/consiglionazionaledellericerche/sigla-main/blob/master/LICENSE)
[![Supported JVM Versions](https://img.shields.io/badge/JVM-8-brightgreen.svg?style=for-the-badge&logo=Java)](https://openjdk.java.net/install/)
[![maven central](https://img.shields.io/maven-central/v/it.cnr.si.sigla/sigla-parent.svg?logo=apache-maven&style=for-the-badge)](https://mvnrepository.com/artifact/it.cnr.si.sigla/sigla-parent)
[![contributors](https://img.shields.io/github/contributors/consiglionazionaledellericerche/sigla-main.svg?logo=github&style=for-the-badge)](https://github.com/consiglionazionaledellericerche/sigla-main/contributors/)
[![Docker Stars](https://img.shields.io/docker/stars/consiglionazionalericerche/sigla-main.svg?logo=docker&style=for-the-badge)](https://hub.docker.com/r/consiglionazionalericerche/sigla-main/)
[![Docker Pulls](https://img.shields.io/docker/pulls/consiglionazionalericerche/sigla-main.svg?logo=docker&style=for-the-badge)](https://hub.docker.com/r/consiglionazionalericerche/sigla-main/)

[![<Build doc Status>](https://circleci.com/gh/consiglionazionaledellericerche/sigla-main.svg?style=svg)](https://app.circleci.com/pipelines/github/consiglionazionaledellericerche/sigla-main)
[![<docs>](https://circleci.com/gh/consiglionazionaledellericerche/sigla-main.svg?style=shield)](https://consiglionazionaledellericerche.github.io/sigla-main)

## Provalo su Google Cloud
[![Run on Google Cloud](https://deploy.cloud.run/button.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/gcp-erpnext.git&cloudshell_print=print.txt&shellonly=true)
 

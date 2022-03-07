#!/bin/bash

#Script to upgrade Helm chart of the ERPNEXT application TO BE TESTED!!!

helm repo update
helm upgrade erpnext-upstream --namespace erpnext frappe/erpnext \
    --set mariadbHost=mariadb.mariadb.svc.cluster.local \
    --set persistence.worker.storageClass=nfs \
    --set persistence.logs.storageClass=nfs \
    --set migrateJob.enable=true

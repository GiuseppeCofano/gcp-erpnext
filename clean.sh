#!/bin/bash

helm delete erpnext-upstream -n erpnext
helm delete mariadb -n mariadb
helm delete cert-manager -n cert-manager
kubectl delete ns nfs
kubectl delete ns ingress-nginx

cd terraform
terraform destroy
cd ..

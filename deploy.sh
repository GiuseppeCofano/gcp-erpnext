#!/bin/bash

function waitForERPNextDeployment() {
  INCREMENT=0
  while [[ $(kubectl get -n erpnext deployment erpnext-${1}-erpnext -o 'jsonpath={..status.conditions[?(@.type=="Available")].status}') != "True" ]]; do
    echo "waiting for deployment erpnext-${1}-erpnext"
    sleep 3
    ((INCREMENT=INCREMENT+1))
    if [[ $INCREMENT -eq 600  ]]; then
      echo "timeout waiting for erpnext-${1}-erpnext"
      exit 1
    fi
  done
}

echo -e "\e[1m\e[4mInstall bitnami/mariadb helm chart\e[0m"
kubectl create namespace mariadb
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install mariadb -n mariadb bitnami/mariadb -f mariadb-local-values.yaml
echo -e "\n"


echo -e "\e[1m\e[4mWait for MariaDB and NFS to be ready\e[0m"
INCREMENT=0
while [[ $(kubectl get -n mariadb pods mariadb-0 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
  echo "waiting for mariadb-0"
  sleep 3
  ((INCREMENT=INCREMENT+1))
  if [[ $INCREMENT -eq 600  ]]; then
    echo "timeout waiting for mariadb-0"
    exit 1
  fi
done
echo -e "\n"

echo -e "\e[1m\e[4mInstall frappe/erpnext helm chart\e[0m"
kubectl create namespace erpnext
kubectl apply -f mariadb-root-password.yaml
helm repo add frappe https://helm.erpnext.com
helm repo update
helm install erpnext-upstream --namespace erpnext frappe/erpnext --version 3.2.42 --set mariadbHost=mariadb.mariadb.svc.cluster.local --set persistence.logs.storageClass=standard-rwx --set persistence.worker.storageClass=standard-rwx --values erpnext-values.yaml
echo -e "\n"

echo -e "\e[1m\e[4mWait for ERPNext deployment to start\e[0m"
waitForERPNextDeployment upstream
echo -e "\n"

#!/bin/bash

source <(grep = config.ini)

cd terraform
terraform init
terraform apply -var="project_id=$project_id"
cd ..

gcloud container clusters get-credentials gke-team-digi-erpnext-poc-001 --region europe-west4 --project $project_id

function waitForERPNextDeployment() {
  INCREMENT=0
  while [[ $(kubectl get -n erpnext deployment erpnext-upstream-erpnext -o 'jsonpath={..status.conditions[?(@.type=="Available")].status}') != "True" ]]; do
    echo "waiting for deployment erpnext-upstream-erpnext"
    sleep 3
    ((INCREMENT=INCREMENT+1))
    if [[ $INCREMENT -eq 600  ]]; then
      echo "timeout waiting for erpnext-upstream-erpnext"
      exit 1
    fi
  done
}

echo -e "\e[1m\e[4mInstall nginx-ingress and cert-manager\e[0m"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml
sleep 10
#helm install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.1 --set installCRDs=true
echo -e "\n"

echo -e "\e[1m\e[4mInstall nfs-server-provisioner\e[0m"
kubectl create namespace nfs
kubectl create -f manifests/nfs-server-provisioner/statefulset.yaml
kubectl create -f manifests/nfs-server-provisioner/rbac.yaml
kubectl create -f manifests/nfs-server-provisioner/class.yaml
echo -e "\n"

echo -e "\e[1m\e[4mInstall bitnami/mariadb helm chart\e[0m"
kubectl create namespace mariadb
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install mariadb -n mariadb bitnami/mariadb -f manifests/mariadb-local-values.yaml --set rootPassword=$password
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
kubectl apply -f manifests/mariadb-root-password.yaml
helm repo add frappe https://helm.erpnext.com
helm repo update
helm install erpnext-upstream --namespace erpnext frappe/erpnext --version $version --set mariadbHost=mariadb.mariadb.svc.cluster.local --set persistence.logs.storageClass=nfs --set persistence.worker.storageClass=nfs --values manifests/erpnext-values.yaml
echo -e "\n"

echo -e "\e[1m\e[4mWait for ERPNext deployment to start\e[0m"
waitForERPNextDeployment upstream
echo -e "\n"

echo -e "Creating demo $site_name site \e[0m"


sed s/%site_name%/$site_name/g manifests/site.yaml > manifests/$site_name.yaml
sed s/%site_name%/$site_name/g manifests/site-ingress.yaml > manifests/$site_name-ingress.yaml
kubectl apply -f manifests/$site_name.yaml
#Workaround to solve communicaiton issue between master nodes and service, ideally one should open the GCP fw to allow the communication to the validating webhook
kubectl delete  validatingwebhookconfigurations ingress-nginx-admission
kubectl apply -f manifests/$site_name-ingress.yaml

echo -e "\e[1m\e[4mWait for site creation to be completed\e[0m"
INCREMENT=0
while [[ $(kubectl get -n erpnext jobs erpnext-upstream-create-site -o 'jsonpath={..status.conditions[?(@.type=="Complete")].status}') != "True" ]]; do
  echo "waiting for erpnext-upstream-create-site"
  sleep 3
  ((INCREMENT=INCREMENT+1))
  if [[ $INCREMENT -eq 900  ]]; then
    echo "timeout waiting for erpnext-upstream-create-site"
    exit 1
  fi
done
INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o 'jsonpath={..status.loadBalancer.ingress[0].ip}')

echo -e "\e[1m\e[4mSite successfully created. Please go the Admin UI to complete site customization\e[0m"
echo -e "\e[1m\e[4mThe Admin UI is available at https://$site_name on the IP address $INGRESS_IP\e[0m"
echo -e "\n"


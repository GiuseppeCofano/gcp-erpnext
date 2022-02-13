#!/bin/bash

echo $project_id

for api in cloudapis cloudresourcemanager compute container file dns
do
	gcloud services enable $api.googleapis.com
done

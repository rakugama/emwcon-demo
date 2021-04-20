# emwcon-demo
Files needed for a demo of deploying mediawiki to kubernetes

## Prerequisites
* docker
* a kubernetes cluster
* a copy of mediawiki/core moved into this repo
* a mysql database

## Instructions
* docker build -t <your tag name> .
* docker push to your docker registry if needed
* update any config values in deployment.yaml
* kubectl apply -f deployment.yaml
** kubectl exec -it <podname> bash
** /var/config/setup.php
* kubectl apply -f service.yaml

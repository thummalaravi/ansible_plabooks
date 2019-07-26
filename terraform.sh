#!/bin/sh
Cd lab
terraform init
terraform apply -input=false -auto-approve

#!/bin/bash

# Update system
yum update -y

# Install dependencies
yum install -y yum-utils

# Install Terraform
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install terraform

# Install Ansible
amazon-linux-extras install epel -y
yum install ansible -y

# Install awscli
sudo dnf update -y
sudo dnf install -y aws-cli
#aws configure



# Verify installations
echo "Terraform version:"
terraform version
echo "Ansible version:"
ansible --version
echo "awscli version:"
aws --version
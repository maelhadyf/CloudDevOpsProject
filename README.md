## terraform

.tmpl
This configuration:

•	Creates S3 bucket and DynamoDB table for backend with prevent_destroy
•	Creates VPC with public subnet
•	Launches two EC2 instances with different sizes
•	Sets up CloudWatch monitoring with dashboards and alarms
•	Generates an Ansible inventory file
•	Includes proper IAM roles for CloudWatch monitoring

Remember to:
•	Replace placeholder values in terraform.tfvars
•	Create an EC2 key pair before applying
•	Update the AMI ID if you're using a different region


To use this configuration:

### 1- Create a terraform.tfvars file:
```hcl
state_bucket_name    = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
dynamodb_table_name  = "your-terraform-locks"
key_name            = "your-key-pair-name"
```
### 2- Initialize and apply Terraform:
```hcl
terraform init
terraform plan
terraform apply
```
### 3- migrate-state to S3
After successful creation of the backend resources:

- Uncomment the backend configuration in root main.tf
Run:
```bash
terraform init -migrate-state
```

---

## Ansible

This will:
•	Install Java and Jenkins on the first EC2 instance
•	Install Java, Git, Docker, and SonarQube, OpenShift-CLI on the second EC2 instance
Important notes:
1.	Make sure your EC2 security groups allow:
o	Port 8080 for Jenkins
o	Port 9000 for SonarQube
2.	System requirements for SonarQube:
o	At least 4GB RAM
o	2 vCPU
3.	After installation:
o	Jenkins will be available at http://jenkins-server:8080
o	SonarQube will be available at http://slave-tools:9000
o	Default SonarQube credentials are admin/admin
o	Jenkins initial admin password will be displayed during installation


### 1- Update the **SSH key**, **inventory** path in `ansible.cfg`:

### 2- Run the playbook:
```bash
ansible-playbook site.yml
```



##############
# First download the Jenkins CLI jar if you haven't already
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

# admin pass
d51e0cc3721148ffbe721bb124372296

# Store credentials in env variables
export JENKINS_USER="your_username"
export JENKINS_PASS="your_password"

# Use with Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS command



## Install suggested plugins using Jenkins CLI:
```bash
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS install-plugin \
  configuration-as-code \
  job-dsl \
  workflow-aggregator \
  git \
  pipeline-stage-view \
  docker-workflow \
  github \
  credentials-binding \
  timestamper
```

# Or for immediate restart
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS safe-restart

# List installed plugins to confirm
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS list-plugins | grep configuration-as-code




You can also combine them in a shell script:
```bash
#!/bin/bash

# Load environment variables
source jenkins.env

# Apply configuration
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS apply-configuration < jenkins.yaml

# Create and run pipeline
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS create-job my-pipeline < Jenkinsfile
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS build my-pipeline
```

## JCasC

### option 1: using credentials plugin


```bash
# Create the directory if it doesn't exist
sudo mkdir -p /var/lib/jenkins/casc_configs

# Create the configuration files
sudo touch /var/lib/jenkins/casc_configs/jenkins.yml
sudo touch /var/lib/jenkins/casc_configs/jenkins.env #no need for this file here as we will use credentials plugin

# Set proper ownership
sudo chown -R jenkins:jenkins /var/lib/jenkins/casc_configs

# Set proper permissions
sudo chmod 600 /var/lib/jenkins/casc_configs/jenkins.env
sudo chmod 644 /var/lib/jenkins/casc_configs/jenkins.yml

# Edit the env file
sudo nano /var/lib/jenkins/casc_configs/jenkins.env

# Edit the yaml file
sudo nano /var/lib/jenkins/casc_configs/jenkins.yml

# Verify the files exist and have correct permissions
ls -la /var/lib/jenkins/casc_configs/

# Restart Jenkins after making changes
sudo systemctl restart jenkins

############# correct the permissions:
sudo chown -R jenkins:jenkins /var/lib/jenkins/config
sudo chmod 644 /var/lib/jenkins/config/jenkins.yml

```

### option 2: using credentials from jenkins.env

1- add credentials section to jenkins.yml
```yaml
credentials:
  system:
    domainCredentials:
      - credentials:
          # SSH credentials for Jenkins slave
          - basicSSHUserPrivateKey:
              scope: GLOBAL
              id: "jenkins-slave-ssh"
              username: "${JENKINS_SLAVE_SSH_USER}"
              description: "SSH key for Jenkins slave"
              privateKeySource:
                directEntry:
                  privateKey: ${JENKINS_SLAVE_SSH_PRIVATE_KEY}

          # Git credentials
          - usernamePassword:
              scope: GLOBAL
              id: "git-credentials"
              username: ${GIT_USERNAME}
              password: ${GIT_PASSWORD}
              description: "Git credentials"

          # Docker registry credentials
          - usernamePassword:
              scope: GLOBAL
              id: "docker-registry-credentials"
              username: ${DOCKER_REGISTRY_USER}
              password: ${DOCKER_REGISTRY_PASSWORD}
              description: "Docker registry credentials"

          # OpenShift credentials
          - string:
              scope: GLOBAL
              id: "openshift-credentials"
              secret: ${OPENSHIFT_TOKEN}
              description: "OpenShift authentication token"
```
2- edit `/var/lib/jenkins/casc_configs/jenkins.env` to include your credentials


3- On Amazon Linux 2023, you can find and modify Jenkins startup options:
```bash
sudo nano /usr/lib/systemd/system/jenkins.service

# Find the [Service] section and add the environment variables:
[Service]
Environment="CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs/jenkins.yml"
Environment="JENKINS_ENV_FILE=/var/lib/jenkins/casc_configs/jenkins.env"
```

After making changes:
```bash
# 1- Reload the systemd daemon:
sudo systemctl daemon-reload

# 2- Restart Jenkins:
sudo systemctl restart jenkins

# 3- Verify the service status:
sudo systemctl status jenkins

# 4- You can also check the actual environment variables being used:
sudo systemctl show jenkins -p Environment
```
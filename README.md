# Cloud DevOps Infrastructure Project

## Infrastructure Diagram



---

## 🎯 Project Overview
This project implements a complete DevOps infrastructure using **Terraform**, **Ansible**, and **Jenkins**. It sets up a fully automated CI/CD environment with monitoring capabilities on AWS.

---

## 🏗️ Architecture Components
- **Jenkins CI/CD Server**
- **SonarQube Code Quality Server**
- **AWS CloudWatch Monitoring**
- **Terraform-managed Infrastructure**
- **Configuration Management with Ansible**

---

## 🚀 Getting Started

### Prerequisites
- AWS Account and configured AWS CLI.
- Terraform installed (v1.0.0+).
- Ansible installed (v2.9+).
- SSH key pair for EC2 instances.

---

## 💫 Infrastructure Deployment

### 1. Terraform Configuration
Our infrastructure as code setup includes:
- **S3 + DynamoDB backend configuration**
- **VPC with public subnet**
- **Two EC2 instances**:
  - `t2.small`
  - `t3.large`
- **CloudWatch monitoring dashboard**
- **IAM roles for monitoring**

---

### Setup Steps

#### 1- Configure variables in `terraform.tfvars`:
```hcl
state_bucket_name    = "XXXXXXXXXXXXXXXXXXXXXXX"
dynamodb_table_name  = "your-terraform-locks"
key_name            = "your-key-pair-name"
```
#### 2- Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```
#### 3- Enable S3 backend:
```bash
terraform init -migrate-state
```

---

### 2. Ansible Configuration
Ansible automates the installation and configuration of:

#### **Primary Instance**
- Jenkins Server
- Java Runtime

#### **Secondary Instance**
- Java 11 & 17
- Git
- Docker
- SonarQube
- OpenShift CLI

---

### Deployment Steps

#### 1. Update `ansible.cfg`
Ensure the Ansible configuration file (`ansible.cfg`) is updated with:
- The path to your SSH private key.
- The path to your inventory file.

Example:
```ini
[defaults]
inventory = ./inventory
private_key_file = ~/.ssh/your-key.pem
remote_user = ec2-user
```
#### 2- Run the playbook:
```bash
ansible-playbook main.yml
```

---

### 3. Jenkins Configuration

#### Plugins Installation
```bash
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS install-plugin \
  configuration-as-code \
  job-dsl \
  workflow-aggregator \
  git \
  pipeline-stage-view \
  docker-workflow \
  github \
  credentials \
  timestamper

# for safe restart
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS safe-restart

# List installed plugins to confirm
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_PASS list-plugins | grep configuration-as-code
```

---

#### Jenkins Configuration as Code (JCasC)

created slave agent, pipline and all required configurations using `jenkins.yml` file

> 📝 **Note:** Change the **slave agent IP** in your configuration files to match the actual IP address of the secondary instance.

```bash
# Create the directory if it doesn't exist
sudo mkdir -p /var/lib/jenkins/config

# move the configuration file to this dest
sudo mv jenkins.yml /var/lib/jenkins/config/

# Set proper ownership
sudo chown -R jenkins:jenkins /var/lib/jenkins/config

# Set proper permissions
sudo chmod 644 /var/lib/jenkins/config/jenkins.yml

# Verify the files exist and have correct permissions
ls -la /var/lib/jenkins/config/

# Restart Jenkins after making changes
sudo systemctl restart jenkins
```

---

#### Configure required credentials:

- slave ssh private key
- git access token
- docker access token
- sonarqube access token
- open shift access token

---

#### Now, Run the Pipeline ✌️✌️✌️✌️✌️✌️✌️

---

## 📝 Important Notes

### 🔒 Security
- Jenkins runs on **port 8080**.
- SonarQube runs on **port 9000**.
- Ensure **security groups** are properly configured to allow access to these ports only from trusted IP addresses.

---

### 📋 SonarQube Requirements
- Minimum **4GB RAM**.
- **2 vCPU cores**.

---

### 🌐 Access Information
- **Jenkins**: [http://jenkins-server-IP:8080](http://jenkins-server:8080)
- **SonarQube**: [http://slave-tools-IP:9000](http://slave-tools:9000)
- Default SonarQube credentials:
  - **Username**: `admin`
  - **Password**: `admin`

---

### 🔍 Monitoring
**CloudWatch dashboards and alarms** are automatically configured to monitor:
- Instance health.
- Resource utilization (CPU, memory, disk).
- Application metrics (e.g., request counts, error rates).

--- 


## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!

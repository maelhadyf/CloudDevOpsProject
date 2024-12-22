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


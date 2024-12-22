variable "ami_id" {
  default = "ami-0230bd60aa48260c6" # Amazon Linux 2023 in us-east-1
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "The ID of the subnet where the instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the instance"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

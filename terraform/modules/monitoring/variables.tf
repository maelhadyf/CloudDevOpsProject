variable "aws_region" {
  default = "us-east-1"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_id" {
  description = "EC2 instance ID to monitor"
  type        = string
}

variable "ami_id" {
  default = "ami-0230bd60aa48260c6" # Amazon Linux 2023 in us-east-1
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.public.id
}

output "jenkins_sg_id" {
  description = "The ID of the Jenkins security group"
  value       = aws_security_group.jenkins.id
}

output "sonarqube_sg_id" {
  description = "The ID of the SonarQube security group"
  value       = aws_security_group.sonarqube.id
}

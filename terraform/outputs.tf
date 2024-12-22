output "jenkins_public_ip" {
  value = module.jenkins_server.public_ip
}

output "jenkins_public_dns" {
  value = module.jenkins_server.public_dns
}

output "slave_public_ip" {
  value = module.slave_tools.public_ip
}

output "slave_public_dns" {
  value = module.slave_tools.public_dns
}

output "state_bucket_name" {
  value = module.backend.state_bucket_name
}

output "dynamodb_table_name" {
  value = module.backend.dynamodb_table_name
}

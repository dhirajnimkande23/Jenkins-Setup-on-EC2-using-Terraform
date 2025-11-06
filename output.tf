output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "ssh_connection_command" {
  description = "SSH command to connect to the Jenkins EC2 instance"
  value       = "ssh -i jenki-keypair.pem ec2-user@${aws_instance.jenkins.public_ip}"
}

output "jenkins_admin_password_command" {
  description = "SSH command to print the Jenkins initial admin password from the instance (run locally)"
  value       = "ssh -i jenkins.pem ec2-user@${aws_instance.jenkins.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}

output "jenkins_url" {
  description = "URL for Jenkins web UI"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

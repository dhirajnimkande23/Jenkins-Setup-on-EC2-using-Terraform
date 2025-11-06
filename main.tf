# Security Group to allow SSH, HTTP, HTPS, Jenkins.

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH, HTTP, HTTPS, and Jenkins"


  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins_security_group"
  }
}

# Launch EC2 instance for Jenkins & provision via SSH
resource "aws_instance" "jenkins" {
  ami                    = "ami-0157af9aea2eef346"
  instance_type          = "t3.small"
  key_name               = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name = "Jenkins-Server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y git docker maven tree",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo dnf install -y java-21-amazon-corretto",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
      "sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo yum upgrade -y",
      "sudo yum install -y jenkins",
      "sudo usermod -aG docker jenkins",
      "sudo systemctl daemon-reexec",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "echo 'Jenkins Admin Password:'",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    ]
  }


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.jenkins.private_key_pem
    host        = self.public_ip
  }

}
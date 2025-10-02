terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Create SSH key pair
resource "tls_private_key" "ansible_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ansible_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ansible_key.public_key_openssh
}

# Create security group
resource "aws_security_group" "ansible_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Ansible-managed instance"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access (for .NET app if needed)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Create EC2 instance
resource "aws_instance" "ansible_host" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ansible_key.key_name
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  subnet_id              = var.subnet_id

  tags = {
    Name        = "${var.project_name}-instance"
    Environment = var.environment
  }

  # Wait for SSH to be available
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ansible_key.private_key_pem
      host        = self.public_ip
    }
  }
}

# Install Ansible and run playbook
resource "null_resource" "ansible_provisioning" {
  depends_on = [aws_instance.ansible_host]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ansible_key.private_key_pem
    host        = aws_instance.ansible_host.public_ip
  }

  # Install Ansible
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "pip3 install --user ansible",
      "echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc",
      "source ~/.bashrc"
    ]
  }

  # Copy Ansible playbook
  provisioner "file" {
    source      = "${path.module}/ansible-playbook.yml"
    destination = "/home/ubuntu/playbook.yml"
  }

  # Run Ansible playbook
  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu",
      "$HOME/.local/bin/ansible-playbook -i 'localhost,' -c local playbook.yml"
    ]
  }
}

# Output important information
output "instance_public_ip" {
  value = aws_instance.ansible_host.public_ip
}

output "instance_id" {
  value = aws_instance.ansible_host.id
}

output "ssh_command" {
  value = "ssh -i private_key.pem ubuntu@${aws_instance.ansible_host.public_ip}"
}

# Save private key to file (for manual SSH access)
resource "local_file" "private_key" {
  content         = tls_private_key.ansible_key.private_key_pem
  filename        = "${path.module}/private_key.pem"
  file_permission = "0600"
}
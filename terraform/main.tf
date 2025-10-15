terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Create EC2 instance
resource "aws_instance" "ansible_host" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  
  tags = {
    Name        = "${var.project_name}-instance"
    Environment = var.environment
  }

  # Install Ansible and execute playbook
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y python3 python3-pip
              pip3 install ansible

              # Create simple playbook if none is provided
              cat > /home/ubuntu/playbook.yml <<EOL
              ---
              - hosts: localhost
                connection: local
                become: yes
                tasks:
                  - name: Ensure system is updated
                    apt:
                      name:
                        - curl
                        - wget
                        - vim
                      state: present
              EOL

              # Run playbook
              ansible-playbook /home/ubuntu/playbook.yml
              EOF
}

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.1.0"
    }
  }
}

# Build an Apache redirector
source "amazon-ebs" "redirector" {
  ami_name      = "apache-redirector"
  instance_type = "t2.micro"
  region        = "us-east-1"
  ssh_username  = "ubuntu"

  # AMI details
  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  # EBS 
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 32
    volume_type           = "gp2"
    delete_on_termination = true
  }

  vpc_filter {
    filters = {
      "isDefault" : "false",
    }
  }

  subnet_filter {
    filters = {
      "state" : "available"
    }
    most_free = true
    random    = false
  }
}

build {
  sources = [
    "source.amazon-ebs.redirector"
  ]

  provisioner "ansible" {
    playbook_file = "../../playbooks/apache_install.yaml"
  }
  provisioner "shell" {
    script = "../../scripts/apache_redirector.sh"
  }
  provisioner "ansible" {
    playbook_file = "../../playbooks/apache_start.yaml"
  }
}
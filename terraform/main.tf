terraform {
  required_version = ">=0.11.13"

  backend "s3" {
    bucket         = "states-awx"
    region         = "eu-west-1"      //No variables
    key            = "states-tfstate"
    dynamodb_table = "states-awx"
    profile        = "default"
  }
}

provider "aws" {
  region  = "${var.region}"
  profile = "default"
}

resource "aws_key_pair" "awx" {
  public_key = "${file("${var.file-ssh-pubkey}")}"
  key_name   = "awx"
}

resource "aws_instance" "awx-dns-server" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.awx.key_name}"
  security_groups = ["${aws_security_group.sgdns.name}"]
  availability_zone = "eu-west-1a"
  private_ip = "172.31.16.11"

  provisioner "remote-exec" {
    inline = [
      "set -x",
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable' -y",
      "sudo apt update",
      "sudo apt install docker-ce python3 python -y",
      "sudo systemctl stop systemd-resolved",
      "sudo systemctl disable systemd-resolved",
      "sudo systemctl mask systemd-resolved",
      "sudo rm /etc/resolv.conf",
      "echo 'nameserver 127.0.0.1' | sudo tee --append /etc/resolv.conf",
      "echo 'nameserver 8.8.8.8' | sudo tee --append /etc/resolv.conf",
      "sudo adduser ubuntu docker",
      /*"sudo curl -sL https://raw.githubusercontent.com/Emergya/docker-registry-expect-scripted-login/master/docker-registry-expect-scripted-login -o /usr/local/bin/docker-registry-expect-scripted-login",
      "sudo chmod +x /usr/local/bin/docker-registry-expect-scripted-login"*/
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.file-ssh-key}")}"
    }
  }
  /*
  provisioner "remote-exec" {
    inline = ["/bin/bash --login -c 'export DOCKER_REGISTRY_URI=${var.emergya_docker_registry_uri}; export DOCKER_REGISTRY_USER=${var.emergya_docker_registry_user}; export DOCKER_REGISTRY_PASS=${var.emergya_docker_registry_pass}; docker-registry-expect-scripted-login'"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.file-ssh-key}")}"
    }
  }*/
  tags {
    Name = "awx-dns-server"
  }
}

resource "aws_security_group" "sgawx" {
  name = "sgawx"

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["${var.ip-emergya}","172.31.16.11/32"]
  }

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["${var.ip-emergya}","172.31.16.11/32"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "sgawx"
  }
}

resource "aws_instance" "awx" {
  ami             = "${var.ami}"
  instance_type   = "${var.instance-type}"
  security_groups = ["${aws_security_group.sgawx.name}"]
  key_name        = "${aws_key_pair.awx.key_name}"
  availability_zone = "eu-west-1a"
  private_ip = "172.31.16.10"

  root_block_device {
    volume_size = 20
  }

  provisioner "file" {
    destination = "/home/ubuntu/docker-compose.yml"
    source      = "docker-compose.yml"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.file-ssh-key}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "set -x",
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable' -y",
      "sudo apt update",
      "sudo apt install docker-ce python3 python -y",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
      "sudo adduser ubuntu docker"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.file-ssh-key}")}"
    }
  }

  provisioner "remote-exec" {
    inline = ["docker-compose -f /home/ubuntu/docker-compose.yml up -d",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.file-ssh-key}")}"
    }
  }

  tags {
    Name = "awx-controller"
  }
}

output "instance" {
  value = "${aws_instance.awx.public_dns}"
}
output "instance-priv" {
  value = "${aws_instance.awx.private_ip}"
}
output "instance-dns" {
  value = "${aws_instance.awx-dns-server.public_dns}"
}
output "instance-dns-priv" {
  value = "${aws_instance.awx-dns-server.private_ip}"
}

variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "ami" {
  type    = "string"
  default = "ami-0204cddbf060b2420"
}

variable "instance-type" {
  type    = "string"
  default = "t2.medium"
}

variable "file-ssh-pubkey" {
  type    = "string"
  default = "awx.pub"
}

variable "file-ssh-key" {
  type    = "string"
  default = "awx"
}

variable "ip-emergya" {
  type    = "list"
  default = ["89.7.187.142/32", "79.146.59.158/32", "79.146.65.242/32","89.140.125.66/32"]
}
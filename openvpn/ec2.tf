provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key = "terraform-template/openvpn/openvpn.tfstate"
    region = "ap-northeast-1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
}

data "http" "ifconfig" {
  url = "https://ifconfig.co"
}

resource "aws_instance" "openvpn" {
  ami = data.aws_ami.ubuntu.image_id
  vpc_security_group_ids = [aws_security_group.openvpn.id]
  instance_type = "t2.micro"
  key_name = "default"

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.private_key)
  }
  provisioner "file" {
    source = "./server"
    destination = "~/openvpn"
  }
  provisioner "remote-exec" {
    inline = ["sudo bash ~/openvpn/setup.sh"]
  }
  provisioner "local-exec" {
    command = "scp -i ${var.private_key} -o StrictHostKeyChecking=no ubuntu@${aws_instance.openvpn.public_ip}:/etc/openvpn/client/* ./client/"
  }
}

resource "aws_security_group" "openvpn" {
  name = "openvpn"
  description = "openvpn"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.ifconfig.body)}/32"]
  }

  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "udp"
    cidr_blocks = ["${chomp(data.http.ifconfig.body)}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "Gateway" {
  value = aws_instance.openvpn.public_ip
}

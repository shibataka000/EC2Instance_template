provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key = "terraform-template/ubuntu/ubuntu.tfstate"
    region = "ap-northeast-1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "http" "ifconfig" {
  url = "https://ifconfig.co"
}

resource "aws_instance" "ubuntu" {
  ami = data.aws_ami.ubuntu.image_id
  vpc_security_group_ids = [aws_security_group.ubuntu.id]
  instance_type = "t3.micro"
  key_name = "default"

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/aws_default")
  }
  provisioner "remote-exec" {
    script = "./cloud-init.sh"
  }
}

resource "aws_security_group" "ubuntu" {
  name = "ubuntu"
  description = "ubuntu"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.ifconfig.body)}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ssh" {
  value = "ssh ubuntu@${aws_instance.ubuntu.public_dns}"
}

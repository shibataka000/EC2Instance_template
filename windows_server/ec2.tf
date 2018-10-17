provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key = "terraform-template/windows-server/windows-server.tfstate"
    region = "ap-northeast-1"
  }
}

data "aws_ami" "windows_server" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
}

data "http" "ifconfig" {
  url = "https://ifconfig.co"
}

resource "aws_instance" "windows_server" {
  ami = "${data.aws_ami.windows_server.image_id}"
  vpc_security_group_ids = ["${aws_security_group.windows_server.id}"]
  instance_type = "t2.medium"
  key_name = "default"
  get_password_data = true
}

resource "aws_security_group" "windows_server" {
  name = "windows_server"
  description = "windows_server"

  ingress {
    from_port = 3389
    to_port = 3389
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

output "server" {
  value = "${aws_instance.windows_server.public_dns}"
}

output "password" {
  value = "${rsadecrypt(aws_instance.windows_server.password_data, file("~/.ssh/aws_default"))}"
}

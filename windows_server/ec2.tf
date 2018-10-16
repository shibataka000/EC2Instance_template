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

data "aws_security_group" "default" {
  name = "default"
}

resource "aws_instance" "windows_server" {
  ami = "${data.aws_ami.windows_server.image_id}"
  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]
  instance_type = "t2.medium"
  key_name = "default"
}

output "instance_id" {
  value = "${aws_instance.windows_server.id}"
}

output "public_dns" {
  value = "${aws_instance.windows_server.public_dns}"
}

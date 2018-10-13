provider "aws" {
  region = "ap-northeast-1"
}

data "aws_ami" "ubuntu_14_04" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
}

data "aws_security_group" "default" {
  name = "default"
}

resource "aws_instance" "openvpn_server" {
  ami = "${data.aws_ami.ubuntu_14_04.image_id}"
  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]
  instance_type = "t2.micro"
  key_name = "default"
  user_data = "${file("server/setup.sh")}"
}

output "public_ip" {
  value = "${aws_instance.openvpn_server.public_ip}"
}

output "instance_id" {
  value = "${aws_instance.openvpn_server.id}"
}

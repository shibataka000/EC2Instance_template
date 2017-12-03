provider "aws" {
  region = "ap-northeast-1"
}

variable "my_ipaddress" {
  default = "0.0.0.0/0"
}

data "aws_security_group" "default" {
  name = "default"
}

resource "aws_security_group_rule" "http" {
  security_group_id = "${data.aws_security_group.default.id}"
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["${var.my_ipaddress}"]
  description = "HTTP"
}

resource "aws_security_group_rule" "https" {
  security_group_id = "${data.aws_security_group.default.id}"
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["${var.my_ipaddress}"]
  description = "HTTPS"
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = "${data.aws_security_group.default.id}"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["${var.my_ipaddress}"]
  description = "SSH"
}

resource "aws_security_group_rule" "rdp" {
  security_group_id = "${data.aws_security_group.default.id}"
  type = "ingress"
  from_port = 3389
  to_port = 3389
  protocol = "tcp"
  cidr_blocks = ["${var.my_ipaddress}"]
  description = "RDP"
}

resource "aws_security_group_rule" "vpn" {
  security_group_id = "${data.aws_security_group.default.id}"
  type = "ingress"
  from_port = 1194
  to_port = 1194
  protocol = "udp"
  cidr_blocks = ["${var.my_ipaddress}"]
  description = "VPN"
}

resource "aws_security_group_rule" "icmp" {
  security_group_id = "${data.aws_security_group.default.id}"
  type = "ingress"
  from_port = -1
  to_port = -1
  protocol = "icmp"
  cidr_blocks = ["${var.my_ipaddress}"]
  description = "ICMP"
}

resource "aws_security_group" "sgdns" {
  name = "sgdns"
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${var.ip-emergya}"]
  }
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["172.31.16.10/32"]
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
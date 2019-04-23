resource "aws_security_group" "sgawx" {
  name   = "sgawx"
  vpc_id = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["${var.ip-emergya}", "${var.private-ip-dns}/32"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["${var.ip-emergya}", "${var.private-ip-dns}/32"]
  }

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["${var.ip-emergya}", "${var.private-ip-dns}/32"]
  }

  tags {
    Name = "sec-grp-awx"
  }
}

resource "aws_security_group" "sgdns" {
  name   = "sgdns"
  vpc_id = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["${var.ip-emergya}"]
  }

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["${var.private-ip-awx}/32"]
  }

  tags {
    Name = "sec-grp-dns"
  }
}

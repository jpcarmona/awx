resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc-cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "jp_vpc"
  }
}

resource "aws_subnet" "pri1" {
  cidr_block              = "${var.pri1_cidr}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.az.names[0]}"

  tags {
    Name = "jp_pri1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "jp_internet-gw"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = "${aws_vpc.vpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

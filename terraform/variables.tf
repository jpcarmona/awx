variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "ami" {
  type    = "string"
  default = "ami-0727f3c2d4b0226d5"
}

variable "instance-type_awx" {
  type    = "string"
  default = "t2.medium"
}

variable "instance-type_dns" {
  type    = "string"
  default = "t2.micro"
}

variable "file-ssh-pubkey" {
  type    = "string"
  default = "ssh-key-awx.pub"
}

variable "file-ssh-key" {
  type    = "string"
  default = "ssh-key-awx"
}

variable "ip-emergya" {
  type    = "list"
  default = ["89.7.187.142/32", "79.146.59.158/32", "79.146.65.242/32", "89.140.125.66/32"]
}

variable "vpc-cidr" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "pri1_cidr" {
  type    = "string"
  default = "10.0.0.0/24"
}

variable "private-ip-awx" {
  type    = "string"
  default = "10.0.0.10"
}

variable "private-ip-dns" {
  type    = "string"
  default = "10.0.0.11"
}

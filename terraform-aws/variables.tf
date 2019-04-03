variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "ami" {
  type    = "string"
  default = "ami-0204cddbf060b2420"
}

variable "instance-type" {
  type    = "string"
  default = "t2.medium"
}

variable "file-ssh-pubkey" {
  type    = "string"
  default = "awx.pub"
}

variable "file-ssh-key" {
  type    = "string"
  default = "awx"
}

variable "ip-emergya" {
  type    = "list"
  default = ["89.7.187.142/32", "79.146.59.158/32", "79.146.65.242/32","89.140.125.66/32"]
}
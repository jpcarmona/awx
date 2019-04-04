output "instance" {
  value = "${aws_instance.awx.public_dns}"
}

output "instance-priv" {
  value = "${aws_instance.awx.private_ip}"
}

output "instance-dns" {
  value = "${aws_instance.awx-dns-server.public_dns}"
}

output "instance-dns-priv" {
  value = "${aws_instance.awx-dns-server.private_ip}"
}

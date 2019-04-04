resource "aws_instance" "awx" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance-type_awx}"
  vpc_security_group_ids = ["${aws_security_group.sgawx.id}"]
  key_name               = "${aws_key_pair.awx.key_name}"
  availability_zone      = "${data.aws_availability_zones.az.names[0]}"
  subnet_id              = "${aws_subnet.pri1.id}"
  private_ip             = "${var.private-ip-awx}"

  root_block_device {
    volume_size = 20
  }

  #  provisioner "file" {
  #    source      = "scripts/script-awx.bash"
  #    destination = "/tmp/script-awx.sh"
  #  }
  #
  #  provisioner "remote-exec" {
  #    inline = [
  #      "chmod +x /tmp/script-awx.sh",
  #      "/tmp/script-awx.sh",
  #    ]
  #  }
  provisioner "remote-exec" {
    script = "scripts/script-awx.bash"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.file-ssh-key}")}"
  }

  tags {
    Name = "jp_awx-controller"
  }
}

resource "aws_instance" "awx-dns-server" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance-type_dns}"
  key_name               = "${aws_key_pair.awx.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sgdns.id}"]
  availability_zone      = "${data.aws_availability_zones.az.names[0]}"
  subnet_id              = "${aws_subnet.pri1.id}"
  private_ip             = "${var.private-ip-dns}"

  #user_data = "${data.template_file.userdata.rendered}"

  provisioner "file" {
    source      = "scripts/script-dns.bash"
    destination = "/tmp/script-dns.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/script-dns.sh",
      "sudo /tmp/script-dns.sh",
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.file-ssh-key}")}"
  }
  tags {
    Name = "jp_awx-dns-server"
  }
}

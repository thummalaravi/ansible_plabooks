


resource "aws_instance" "acess" {
  ami           = "ami-05c1fa8df71875112"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.project16_1b.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  #key_name = "${var.key_name}"
  tags=  {
        Name = "acess"
  }
}

resource "aws_instance" "control" {
  ami           = "ami-05c1fa8df71875112"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.project16_2a.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  #key_name = "${var.key_name}"
  tags = {
        Name = "control"
  }
}

resource "aws_instance" "web01" {
  ami           = "ami-05c1fa8df71875112"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.project16_2c.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  #key_name = "${var.key_name}"
  tags =  {
        Name = "web01"
  }
}

resource "aws_instance" "web02" {
  ami           = "ami-05c1fa8df71875112"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.project16_2c.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  #key_name = "${var.key_name}"
  tags = {
        Name = "web02"
  }
}

resource "aws_instance" "db_server" {
  ami           = "ami-05c1fa8df71875112"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.project16_2b.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  #key_name = "${var.key_name}"
  tags = {
        Name = "db_server"
  }
}


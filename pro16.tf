


resource "aws_instance" "acess" {
  ami           = "ami-08fba854c7827042b"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.project16_public_subnet_a1.id}"
  vpc_security_group_ids = ["${aws_security_group.project16_sg.id}"]
  #key_name = "${var.key_name}"
  tags=  {
        Name = "acess"
  }
}

resource "aws_instance" "control" {
  ami           = "ami-08fba854c7827042b"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.project16_pvt_subnet_a2.id}"
  vpc_security_group_ids = ["${aws_security_group.project16_sg.id}"]
  #key_name = "${var.key_name}"
  tags = {
        Name = "control"
  }
}

resource "aws_instance" "web01" {
  ami           = "ami-08fba854c7827042b"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.project16_pvt_subnet_b2.id}"
  vpc_security_group_ids = ["${aws_security_group.project16_sg.id}"]
  #key_name = "${var.key_name}"
  tags =  {
        Name = "web01"
  }
}

resource "aws_instance" "web02" {
  ami           = "ami-08fba854c7827042b"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.project16_pvt_subnet_c2.id}"
  vpc_security_group_ids = ["${aws_security_group.project16_sg.id}"]
  #key_name = "${var.key_name}"
  tags = {
        Name = "web02"
  }
}

resource "aws_instance" "db_server" {
  ami           = "ami-08fba854c7827042b"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.project16_pvt_subnet_b2.id}"
  vpc_security_group_ids = ["${aws_security_group.project16_sg.id}"]
  #key_name = "${var.key_name}"
  tags = {
        Name = "db_server"
  }
}


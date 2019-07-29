resource "aws_vpc" "project16" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "project16"
  }
}


resource "aws_subnet" "project16_1a" {

  vpc_id     = "${aws_vpc.project16.id}"
  cidr_block = "10.10.0.0/27"
  map_public_ip_on_launch = true
   availability_zone = "us-east-2a"
  tags = {
      Name = "project16_1a"
    }
}



resource "aws_subnet" "project16_1b" {
vpc_id     = "${aws_vpc.project16.id}"
  cidr_block = "10.10.0.32/27"
 map_public_ip_on_launch = true
   availability_zone = "us-east-2b"
  tags = {
    Name = "project16_1b"
  }
}

resource "aws_subnet" "project16_1c" {
vpc_id     = "${aws_vpc.project16.id}"
  cidr_block = "10.10.0.64/27"
 map_public_ip_on_launch = true
  availability_zone = "us-east-2c"

  tags = {
    Name = "project16_1c"
  }
}

#pvt subnet a2
resource "aws_subnet" "project16_2a" {
  vpc_id     = "${aws_vpc.project16.id}"
  cidr_block = "10.10.0.96/27"
  availability_zone = "us-east-2a"
  tags = {
    Name = "project16_2a"
  }
}

#pvt subnet b2
resource "aws_subnet" "project16_2b" {
  vpc_id     = "${aws_vpc.project16.id}"
  cidr_block = "10.10.0.128/27"
  availability_zone = "us-east-2b"
  tags = {
    Name = "project16_2b"
  }
}

#pvt subnet c2
resource "aws_subnet" "project16_2c" {
  vpc_id     = "${aws_vpc.project16.id}"
  cidr_block = "10.10.0.160/27"
  availability_zone = "us-east-2c"
  tags = {
    Name = "project16_2c"
  }
}

resource "aws_default_route_table" "project16_drt" {

 default_route_table_id = "${aws_vpc.project16.default_route_table_id}"
 tags = {
 Name = "project16_drt"
 }
route {
   cidr_block = "0.0.0.0/0"
   gateway_id = "${aws_internet_gateway.project16.id}"
 }
}

# public route table association
resource "aws_route_table_association" "project16_rt_ass1" {

 subnet_id      = "${aws_subnet.project16_1a.id}"
route_table_id = "${aws_default_route_table.project16_drt.id}"

}

# public route table association
resource "aws_route_table_association" "project16_rt_ass2" {

 subnet_id      = "${aws_subnet.project16_1b.id}"
route_table_id = "${aws_default_route_table.project16_drt.id}"

}

# public route table association
resource "aws_route_table_association" "project16_rt_ass3" {

 subnet_id      = "${aws_subnet.project16_1c.id}"
route_table_id = "${aws_default_route_table.project16_drt.id}"

}

resource "aws_route_table" "Private"{
        vpc_id     = "${aws_vpc.project16.id}"

route {
cidr_block = "0.0.0.0/0"
gateway_id = "${aws_nat_gateway.gw.id}"
}
        tags = {
        Name = "project16"
        }
}

# pvt route table association
resource "aws_route_table_association" "project16_rt_ass_pvt1" {

 subnet_id      = "${aws_subnet.project16_2a.id}"
route_table_id = "${aws_route_table.Private.id}"

}

# pvt route table association
resource "aws_route_table_association" "project16_rt_ass_pvt2" {

 subnet_id      = "${aws_subnet.project16_2b.id}"
route_table_id = "${aws_route_table.Private.id}"

}

# pvt route table association
resource "aws_route_table_association" "project16_rt_ass_pvt3" {

 subnet_id      = "${aws_subnet.project16_2c.id}"
route_table_id = "${aws_route_table.Private.id}"

}

resource "aws_internet_gateway" "project16" {
  vpc_id = "${aws_vpc.project16.id}"

  tags = {
 Name = "project16"
  }
}

resource "aws_eip" "nat" {

  vpc = true

  tags = {
    Name = "project16"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.project16_1b.id}"

  tags = {
    Name = "project16"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id = "${aws_vpc.project16.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks =[ "0.0.0.0/0"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
        }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
        }

                  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

  }


  tags = {
    Name = "allow_all"
  }
}

resource "aws_launch_configuration" "project16-launchconfig" {
  name_prefix          = "project16-launchconfig"
  image_id             = "${data.aws_ami.ubuntu.id}"
  instance_type        = "t2.micro"
  key_name             = "deployer-key"
  security_groups      = ["${aws_security_group.allow_tls.id}"]
}

resource "aws_autoscaling_group" "project16-autoscaling" {
  name                 = "project16-autoscaling"
  vpc_zone_identifier  = ["${aws_subnet.project16_2b.id}"]
  launch_configuration = "${aws_launch_configuration.project16-launchconfig.name}"
  min_size             = 1
  max_size             = 2
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true

# Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
      key = "Name"
      value = "ec2 instance"
      propagate_at_launch = true
  }
}
resource "aws_security_group" "elb-securitygroup" {
  vpc_id = "${aws_vpc.project16.id}"
  name = "elb"
  description = "security group for load balancer"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "project16"
  }
}

resource "aws_elb" "my-elb" {
  name = "my-elb"
  subnets = ["${aws_subnet.project16_1a.id}", "${aws_subnet.project16_1b.id}", "${aws_subnet.project16_1c.id}"]
  security_groups = ["${aws_security_group.elb-securitygroup.id}"]
 listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }

  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
  tags = {
    Name = "project16"
  }
}
resource "aws_autoscaling_attachment" "link" {

 autoscaling_group_name = "${aws_autoscaling_group.project16-autoscaling.id}"
 elb                  = "${aws_elb.my-elb.id}"

}

# route 53
resource "aws_route53_zone" "project16" {
 name = "vss-carrentals.ga"
}

resource "aws_route53_record" "project16" {
 zone_id = "${aws_route53_zone.project16.zone_id}"
 name    = "vss-carrentals.ga"
 type    = "A"

 alias {
   name                   = "${aws_elb.my-elb.dns_name}"
   zone_id                = "${aws_elb.my-elb.zone_id}"
   evaluate_target_health = true
 }
}




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


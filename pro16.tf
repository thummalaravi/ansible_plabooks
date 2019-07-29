
# vpc creation.
resource "aws_vpc" "project16_customised" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "project16_customised"
  }
}

#public subnet a1
resource "aws_subnet" "project16_public_subnet_a1" {
  vpc_id     = "${aws_vpc.project16_customised.id}"
  cidr_block = "10.10.0.0/27"
  availability_zone = "us-east-2a"
  tags = {
    Name = "project16_public_subnet_a1"
  }
}
# public subnet  b1
resource "aws_subnet" "project16_public_subnet_b1" {
  vpc_id     = "${aws_vpc.project16_customised.id}"
  cidr_block = "10.10.0.32/27"
  availability_zone = "us-east-2b"
  tags = {
    Name = "project16_public_subnet_b1"
  }
}

# public subnet  c1
resource "aws_subnet" "project16_public_subnet_c1" {
  vpc_id     = "${aws_vpc.project16_customised.id}"
  cidr_block = "10.10.0.64/27"
  availability_zone = "us-east-2c"
  tags = {
    Name = "project16_public_subnet_c1"
  }
}

#pvt subnet a2
resource "aws_subnet" "project16_pvt_subnet_a2" {
  vpc_id     = "${aws_vpc.project16_customised.id}"
  cidr_block = "10.10.0.96/27"
  availability_zone = "us-east-2a"
  tags = {
    Name = "project16_pvt_subnet_a2"
  }
}

# pvt subnet  b2
resource "aws_subnet" "project16_pvt_subnet_b2" {
  vpc_id     = "${aws_vpc.project16_customised.id}"
  cidr_block = "10.10.0.128/27"
  availability_zone = "us-east-2b"
  tags = {
    Name = "project16_pvt_subnet_b2"
  }
}

# pvt subnet  c2
resource "aws_subnet" "project16_pvt_subnet_c2" {
  vpc_id     = "${aws_vpc.project16_customised.id}"
  cidr_block = "10.10.0.160/27"
  availability_zone = "us-east-2c"
  tags = {
    Name = "project16_pvt_subnet_c2"
  }
}

# Default route table
resource "aws_default_route_table" "project16_rt" {
  default_route_table_id = "${aws_vpc.project16_customised.default_route_table_id}"
  tags = {
    Name = "project16_rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.project16_igw.id}"
  }
}

# creating new route table
resource "aws_route_table" "project16_rt_pvt" {
  vpc_id = "${aws_vpc.project16_customised.id}"
  tags = {
    Name = "project16_rt_pvt" 
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.project16_nat.id}"
  }
}

# creating Internet gateway
resource "aws_internet_gateway" "project16_igw" {
  vpc_id = "${aws_vpc.project16_customised.id}"
  tags = {
    Name = "project16_igw"
  }
}

# creating elastic ip
resource "aws_eip" "project16_nat_eip" {
  vpc = true
}

#creating nat gateway
resource "aws_nat_gateway" "project16_nat"{
  subnet_id   = "${aws_subnet.project16_public_subnet_a1.id}"
  depends_on = ["aws_eip.project16_nat_eip"]
  allocation_id = "${aws_eip.project16_nat_eip.id}"
  tags = {
    Name =  "project16_nat"
  }
}

# public route table_1a association
resource "aws_route_table_association" "project16_rt_ass_1a" {
  subnet_id      = "${aws_subnet.project16_public_subnet_a1.id}"
  route_table_id = "${aws_default_route_table.project16_rt.id}"
}

# public route table-1b association
resource "aws_route_table_association" "project16_rt_ass_1b" {
  subnet_id      = "${aws_subnet.project16_public_subnet_b1.id}"
  route_table_id = "${aws_default_route_table.project16_rt.id}"
}

# public route table_1c association
resource "aws_route_table_association" "project16_rt_ass_1c" {
  subnet_id      = "${aws_subnet.project16_public_subnet_c1.id}"
  route_table_id = "${aws_default_route_table.project16_rt.id}"
}

# pvt routetable_2a association 
resource "aws_route_table_association" "project16_rt_ass_2a" {
  subnet_id      = "${aws_subnet.project16_pvt_subnet_a2.id}"
  route_table_id = "${aws_route_table.project16_rt_pvt.id}"
}

# pvt routetable_2b association
resource "aws_route_table_association" "project16_rt_ass_2b" {
  subnet_id      = "${aws_subnet.project16_pvt_subnet_b2.id}"
  route_table_id = "${aws_route_table.project16_rt_pvt.id}"
}

# pvt routetable_2c association
resource "aws_route_table_association" "project16_rt_ass_c2" {
  subnet_id      = "${aws_subnet.project16_pvt_subnet_c2.id}"
  route_table_id = "${aws_route_table.project16_rt_pvt.id}"
}

# creating security group
resource "aws_security_group" "project16_sg" {
  name = "project16_sg"
  vpc_id = "${aws_vpc.project16_customised.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 }



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
  associate_public_ip_address = "true"
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
  associate_public_ip_address = "true"
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
  associate_public_ip_address = "true"
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
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.project16_pvt_subnet_b2.id}"
  vpc_security_group_ids = ["${aws_security_group.project16_sg.id}"]
  #key_name = "${var.key_name}"
  tags = {
        Name = "db_server"
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

resource "aws_vpc" "project15" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "project15"
  }
}


resource "aws_subnet" "project15" {
vpc_id     = "${aws_vpc.project15.id}"
cidr_block = "10.0.1.0/24"
map_public_ip_on_launch = true
tags = {
    Name = "project15"
  }
}



resource "aws_subnet" "public" {
vpc_id     = "${aws_vpc.project15.id}"
  cidr_block = "10.0.0.48/28"
 map_public_ip_on_launch = true

  tags = {
    Name = "project15"
  }
}

resource "aws_route_table" "public"{

        vpc_id     = "${aws_vpc.project15.id}"

route {
cidr_block = "0.0.0.0/0"
gateway_id = "${aws_internet_gateway.project15.id}"

}
tags = {
    Name = "project15"
  }

}

resource "aws_default_route_table" "project15_rt" {

 default_route_table_id = "${aws_vpc.project15.default_route_table_id}"
 tags = {
 Name = "project15_rt"
 }
route {
   cidr_block = "0.0.0.0/0"
   gateway_id = "${aws_internet_gateway.project15.id}"
 }
}




# public route table association
resource "aws_route_table_association" "project15_rt_ass" {

 subnet_id      = "${aws_subnet.project15.id}"
route_table_id = "${aws_route_table.public.id}"

}








resource "aws_route_table" "Private"{
        vpc_id     = "${aws_vpc.project15.id}"

route {
cidr_block = "0.0.0.0/0"
gateway_id = "${aws_nat_gateway.gw.id}"
}
        tags = {
        Name = "project15"
        }
}











resource "aws_internet_gateway" "project15" {
  vpc_id = "${aws_vpc.project15.id}"

  tags = {
 Name = "project15"
  }
}

resource "aws_eip" "nat" {

  vpc = true

  tags = {
    Name = "project15"
  }
}



resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"

  tags = {
    Name = "project15"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id = "${aws_vpc.project15.id}"

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

resource "aws_launch_configuration" "example-launchconfig" {
  name_prefix          = "example-launchconfig"
  image_id             = "${data.aws_ami.ubuntu.id}"
  instance_type        = "t2.micro"
  key_name             = "deployer-key"
  security_groups      = ["${aws_security_group.allow_tls.id}"]
}

resource "aws_autoscaling_group" "example-autoscaling" {
  name                 = "example-autoscaling"
  vpc_zone_identifier  = ["${aws_subnet.public.id}"]
  launch_configuration = "${aws_launch_configuration.example-launchconfig.name}"
  min_size             = 1
  max_size             = 2
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true

  tag {
      key = "Name"
      value = "ec2 instance"
      propagate_at_launch = true
  }
}


resource "aws_security_group" "elb-securitygroup" {
  vpc_id = "${aws_vpc.project15.id}"
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
    Name = "project15"
  }
}

resource "aws_elb" "my-elb" {
  name = "my-elb"
  subnets = ["${aws_subnet.public.id}"]
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
    Name = "project15"
  }
}


resource "aws_autoscaling_attachment" "link" {

 autoscaling_group_name = "${aws_autoscaling_group.example-autoscaling.id}"
 elb                  = "${aws_elb.my-elb.id}"

}




# route 53
resource "aws_route53_zone" "project15" {
 name = "vss-carrentals.ga"
}

resource "aws_route53_record" "project15" {
 zone_id = "${aws_route53_zone.project15.zone_id}"
 name    = "vss-carrentals.ga"
 type    = "A"

 alias {
   name                   = "${aws_elb.my-elb.dns_name}"
   zone_id                = "${aws_elb.my-elb.zone_id}"
   evaluate_target_health = true
 }
}


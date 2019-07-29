variable "vpc_cidr" {
	default = "10.10.0.0/16"
}

variable "subnet_cidrs_public" {
  type    = "list"
  default = ["10.10.0.0/27", "10.10.0.32/27","10.10.0.96/27"]
}

variable "subnet_cidrs_private" {
  type    = "list"
  default = ["10.10.0.128/27", "10.10.0.160/27", "10.10.0.192/27"]
}

variable "public_name" {
	type    = "list"
	default = ["public-1", "public-2", "public-3"]
}

variable "private_name" {
	type    = "list"
	default = ["private-1", "private-2",  "private-3"]
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
  type = "list"
}

variable "ami" {
	default = "ami-08fba854c7827042b"
}

variable "instance_type" {
	default = "t2.micro"
}

variable "key_name" {
  description = "Key name for SSHing into EC2"
  default = "master"
}

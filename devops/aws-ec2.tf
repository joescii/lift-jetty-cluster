resource "aws_security_group" "lift_instance_sg" {
  name = "lift-instance-sg"
  description = "SG applied to each lift app server instance"
	vpc_id = "${module.vpc.vpc_id}"

  # HTTP access only from load balancer
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = ["${aws_security_group.lift_elb_sg.id}"]
  }
  
  # Open communication to anything in the VPC (particularly the RDS instance)
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${module.vpc.cidr_block}"]
  }
}

resource "aws_security_group" "lift_elb_sg" {
  name = "lift-elb-sg"
  description = "SG applied to the elastic load balancer"
	vpc_id = "${module.vpc.vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open communication up to anything in the VPC (particularly the Lift instances)
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${module.vpc.cidr_block}"]
  }
}


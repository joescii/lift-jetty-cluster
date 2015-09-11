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

resource "aws_launch_configuration" "lift_as_conf" {
  name = "lift-as-launch-config-${var.timestamp}"
  depends_on = "template_file.packer"
  image_id = "${template_file.packer.vars.ami}"
  instance_type = "t2.micro"
  key_name = "${var.ec2_key_name}"
  security_groups = [
    "${aws_security_group.lift_instance_sg.id}",
    "${module.vpc.bastion_accessible_sg_id}"
  ]
  user_data = "${template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "lift_as" {
  availability_zones = ["${module.region.zone_A}", "${module.region.zone_B}"]
  vpc_zone_identifier = ["${module.vpc.zone_A_private_id}", "${module.vpc.zone_B_private_id}"]
  name = "lift-autoscaling-group-${var.timestamp}"
  desired_capacity = 2
  max_size = 2
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.lift_as_conf.id}"
  load_balancers = ["${aws_elb.lift-elb.name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "lift-elb" {
  name = "lift-elb-${var.timestamp}"
  subnets = ["${module.vpc.zone_A_public_id}", "${module.vpc.zone_B_public_id}"]
  security_groups = ["${aws_security_group.lift_elb_sg.id}"]
  internal = false
  cross_zone_load_balancing = true
  depends_on = "aws_launch_configuration.lift_as_conf"
  
  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http" 
  }
 
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/"
    interval = 5
  }
 
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_app_cookie_stickiness_policy" "lift_stickiness_policy" {
  name = "lift-policy"
  load_balancer = "${aws_elb.lift-elb.id}"
  lb_port = 80
  cookie_name = "JSESSIONID"
}

resource "template_file" "user_data" {
  filename = "./user_data.sh"
  
  vars {
    db_host = "${aws_db_instance.lift_db.address}"
    db_port = "${aws_db_instance.lift_db.port}"
  }
}

resource "template_file" "packer" {
  filename = "/dev/null"
  depends_on = "template_file.packer_runner"
  vars {
    ami = "${file(var.ami_txt)}"
#    ami = "ami-5153a915"
  }
}
resource "template_file" "packer_runner" {
  filename = "/dev/null"
  
  provisioner "local-exec" {
    command = "./bake.sh ${var.access_key} ${var.secret_key} ${module.region.region} ${module.vpc.vpc_id} ${module.vpc.zone_B_public_id} ${module.vpc.packer_sg_id} ${module.region.ubuntu_precise_12_04_amd64} ${var.db_password} ${var.timestamp}"
  }
}
variable "ami_txt" {
  default = "./ami.txt"
}

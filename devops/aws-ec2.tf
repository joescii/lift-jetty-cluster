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
  
  # Open communication back to the ELB
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.lift_elb_sg.id}"]
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

  # Open communication up to the instances
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${module.vpc.cidr_block}"]
  }
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
#    ami = "${file(var.ami_txt)}"
    ami = "ami-e536cda1"
  }
}
resource "template_file" "packer_runner" {
  filename = "/dev/null"
  
#  provisioner "local-exec" {
#    command = "./bake.sh ${var.access_key} ${var.secret_key} ${module.region.region} ${module.vpc.vpc_id} ${module.vpc.zone_B_public_id} ${module.vpc.packer_sg_id} ${module.region.ubuntu_precise_12_04_amd64} ${var.db_password} ${var.timestamp}"
#  }
}

variable "ami_txt" {
  default = "./ami.txt"
}

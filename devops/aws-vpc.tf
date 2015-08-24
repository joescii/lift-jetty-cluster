module "vpc" {
  source = "github.com/joescii/aws-terraform-modules/vpc-2-zones"
  
  vpc_name = "lift-jetty-cluster"
  ec2_key_name = "${var.ec2_key_name}"
  region = "${var.region}"
  zone_A = "${var.zone_A}"
  zone_B = "${var.zone_B}"
  nat_ami = "${var.nat_ami}"
  bastion_ami = "${var.bastion_ami}"
}
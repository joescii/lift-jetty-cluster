module "vpc" {
  source = "github.com/joescii/aws-terraform-modules/vpc-2-zones"
  
  vpc_name = "lift-jetty-cluster"
  ec2_key_name = "${var.ec2_key_name}"
  region = "${module.region.region}"
  zone_A = "${module.region.zone_A}"
  zone_B = "${module.region.zone_B}"
  nat_ami = "${module.region.nat_ami}"
  bastion_ami = "${module.region.enhanced_bastion_ami}"
  ci_server_cidr_block = "${var.ci_server_cidr_block}"
  
  # With the key file, you will be able to SSH directly to the bastion
  # and then SSH to the machines whenever that is preferable to tunneling.
  provisioner "file" {
    connection {
      user = "ubuntu"
      host = "${self.bastion_host}"
      key_file = "./key.pem"
    }

    source = "./key.pem"
    destination = "/home/ubuntu/lift.pem"
  }
}
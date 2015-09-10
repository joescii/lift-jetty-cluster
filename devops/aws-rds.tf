resource "aws_db_subnet_group" "all_azs" {
  name = "all-azs"
  description = "Subnet group covering each availability zone"
  subnet_ids = [
    "${module.vpc.zone_A_private_id}", 
    "${module.vpc.zone_B_private_id}"
  ]
}

resource "aws_security_group" "lift_db_sg" {
  name = "tf-portal-user-db-rds-sg"
  description = "RDS security group for the User DB"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.lift_instance_sg.id}"
    ]
  }
}



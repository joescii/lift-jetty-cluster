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

resource "aws_db_instance" "lift_db" {
  identifier = "lift-db"
  allocated_storage = 5
  engine = "mysql"
  engine_version = "5.6.19a"
  instance_class = "db.t2.micro"
  name = "LIFT"
  username = "${var.db_username}"
  password = "${var.db_password}"
  vpc_security_group_ids = [
    "${module.vpc.bastion_accessible_sg_id}",
    "${aws_security_group.lift_db_sg.id}"
  ]
  db_subnet_group_name = "${aws_db_subnet_group.all_azs.name}"
  multi_az = "true"
}


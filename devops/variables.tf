variable "access_key" {}
variable "secret_key" {}

# All of the following variables must change if you want to use a different AWS region,
# including the AMIs.
variable "region" {
  default = "us-west-1"
}
variable "zone_A" {
  default = "us-west-1b"
}
variable "zone_B" {
  default = "us-west-1c"
}
variable "nat_ami" {
	default = "ami-ada746e9"
}
variable "bastion_ami" {
	default = "ami-896d93cd"
}
variable "ec2_key_name" {
  default = "sandbox"
}

# The timestamp will be provided by our deploy.sh script
variable "timestamp" {}
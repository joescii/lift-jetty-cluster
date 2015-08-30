variable "access_key" {}
variable "secret_key" {}

# Used to select the region template from github.com/joescii/aws-terraform-modules/
variable "ec2_key_name" {
  default = "sandbox"
}

# The timestamp will be provided by our deploy.sh script
variable "timestamp" {}

# The two db variables will be provided to the deploy.sh script as environment variables
variable "db_username" {}
variable "db_password" {}

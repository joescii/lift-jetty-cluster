variable "access_key" {}
variable "secret_key" {}

variable "ec2_key_name" {
  default = "sandbox"
}

# The CIDR block where the CI server running terraform is located.
# The deploy.sh performs a query to restrict this to an exact IP.
variable "ci_server_cidr_block" {
  default = "0.0.0.0/0"
}

# The timestamp will be provided by our deploy.sh script
variable "timestamp" {}

# The two db variables will be provided to the deploy.sh script as environment variables
variable "db_username" {}
variable "db_password" {}

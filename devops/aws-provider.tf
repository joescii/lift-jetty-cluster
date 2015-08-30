# This sorta bootstraps terraform into AWS mode.
# I like it in a separate file so it can be dropped into any project with
# AWS infrastructure defined.

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${module.region.region}"
}


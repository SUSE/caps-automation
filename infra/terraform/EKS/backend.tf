terraform {
  backend "s3" {
    bucket = "ecosystemci"
    key    = "ci.terraform.tfstate"
    region = "eu-central-1"
  }
}
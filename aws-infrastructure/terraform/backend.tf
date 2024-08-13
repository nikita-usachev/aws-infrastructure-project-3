# backend

terraform {
  backend "s3" {
    bucket  = "terraform-states-bucket-name"
    key     = "infra"
    region  = "us-east-2"
    encrypt = true
  }
}

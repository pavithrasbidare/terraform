# Configure Terraform Backend
terraform {
  backend "s3" {
    bucket         = "usecase-1"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}
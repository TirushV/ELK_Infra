# Stores terraform state file in s3
terraform {
  backend "s3" {
    bucket = "elasticbeanstalk-ap-south-1-921874535331" # Bucket name should be changed
    key    = "Myfolder/file/terraform.tfstate"
    region = "ap-south-1"
  }
}
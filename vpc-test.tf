resource "aws_vpc" "main" {
  cidr_block       = "10.80.0.0/26"
  instance_tenancy = "default"

  tags = {
    Name = "tf-codebuild"
  }
}

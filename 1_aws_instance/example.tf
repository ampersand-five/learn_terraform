provider "aws" {
  profile = "de-dev"
  region  = "us-west-2"
}

resource "aws_instance" "delete_me_after_" {
  ami             = "ami-0d6621c01e8c2de2c"
  instance_type   = "t2.micro"
  subnet_id       = "subnet-"
#   security_groups = ["sg-"]
  vpc_security_group_ids = ["sg-"]
  tags = {
    Name = "delete_me_after_"
    bc = ""
    created_by = ""
    org = ""
    team = ""
  }
}
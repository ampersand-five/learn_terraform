provider "aws" {
  profile = ""
  region  = "us-west-2"
}

resource "aws_instance" "_delete_me_after_" {
  ami             = "ami-0d6621c01e8c2de2c"
  instance_type   = "t2.micro"
  subnet_id       = "subnet-"
#   security_groups = ["sg-"]

    provisioner "local-exec" {
        command = "echo ${aws_instance._delete_me_after_.public_ip} > ip_address.txt"
    }

  vpc_security_group_ids = ["sg-"]
  tags = {
    Name = "_delete_me_after_"
    bc = ""
    created_by = ""
    org = ""
    team = ""
  }
}


# adding an elastic ip
resource "aws_eip" "ip" {
    vpc = true
    instance = aws_instance._delete_me_after_.id
}
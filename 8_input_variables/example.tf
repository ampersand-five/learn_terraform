provider "aws" {
  profile    = "default"
  region     = var.region
}

resource "aws_instance" "example" {
  # here we are using the ami variable map type and using the region variable as the key for the map
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
}

output "ip" {
	value = aws_eip.ip.public_ip
}
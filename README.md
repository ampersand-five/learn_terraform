# Learning Terraform

## Notes
- Provider blocks define the cloud you deploy to
- Resource blocks are the specific piece of infrastructure we want to create
    - It has two parameters
      - Resource Type: name of the actual resource from the cloud you are deploying to (defined by HashiCorp, meaning
that an aws ec2 instance in Terraform is called/referred to as aws_instance)
        - The prefix on the type maps to the provider
      - Resource Name: identifier string to identify the resource
    - Resources can be a physical component, ec2 instance, or a logical resource like a Heroku app
```
         real resource      id
              |             |
              v             v    
resource "aws_instance" "example" {
    ami = "ami-21342345"
    instance_type = "t2.micro"
}
```

👨‍💻
#### Workflows
- Scope
- Author
- Initialize
- Plan & Apply


- Terraform keeps track of the id's of created resources in the generated state file -> how it knows
what it is managing
- `terraform init` is just needed once per folder location to download locally the libraries associated
with the provider you are using

Equivalent?:
security_groups = ["sg-0000"]
vpc_security_group_ids = ["sg-0000"] --> seems to be the preferred choice by Terraform


- Depends on syntax can create explicit build order dependencies
  -   `depends_on = [aws_s3_bucket.example]`

- Provisioners: used to setup things on an ec2 instance (or other things) after it's started
  - Example Local machine:
  - This example uses local-exec which runs on the machine that is doing the terraform apply
  - ```
        provisioner "local-exec" {
        command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
    }
    ```
    - Example Remote execution (will happen in the resource where the provisioner block is defined):
    - ```
        provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/terraform.pub")
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name #----- this tells the resourse which key to use for remote connections
  ami           = "ami-04590e7389a6e577c"
  instance_type = "t2.micro"

  connection { #---- to use a remote provisioner, you need to specify a connection type (ssh or other), this will also need a key pair for ssh connections
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/terraform")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx"
    ]
  }
}

    ```

- If a resource is created but the provisioner fails, then terraform will mark the resource as tainted
  - Tainted refers to resources that exist but are not safe to use because the provisioning failed
  - During the next apply, Terraform will destroy tainted resources and try to re-create them
- Provisioners can be setup to run only on a destroy for a resource. Meaning they would run any scripts to get data off the instance before it's shut down, or anything else you would want a resource to do before it is deleted
- 
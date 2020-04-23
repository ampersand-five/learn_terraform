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




## Variables
- Files can be called anything since terraform will just load anything in a directory that ends in .tf
- You can create variable files that hold variables specifically
  - File must be named terraform.tfvars or for a different name you can put *.auto.tfvars -> These files will be read as variable files
  - If these files are present in the current directory, terraform will automatically load them to populate variables
- variables.tf files are for defining variables
  - default values can be set here. If no assignment happens ina terraform.tfvars file, the default will be used
- terraform.tfvars files are for setting the actual values for the variables in the variables files

- Typing of variables
  - Example: If a map's data is set in the terraform.tfvars file, the variable must still be declared
    separately with either `type="map" or default={}

#### Outputs
- Can be defined in any *.tf file
- Outputs variable at end of `terraform apply`
- You can query output variables after an apply by usign `terraform output <variable>` like this `terraform output ip`
  - Useful for scripts to get outputs


## Modules
- A module is simply a folder with .tf files in it
  - In that sense, everything is a module. The folder you call terraform apply from is the root module
  - You can call modules from other folders with a module block in your .tf file.
  - You can use local or remote modules. It is possible to setup a TF registry or use github or http urls for remote modules
- Terraform has a public registry of useful modules you can use
- To reference where a module is, you use the `source` argument
  - There is also a `version` arguments you can use to specify a version of the module to use
- Other arguments that are defined in a module block are treated as input variables to the modules themselves
- Modules can have output variables
  - You can reference them using: `module.<module_name>.<output_var_name>`
- `terraform init` pulls in any specified modules
- Typical file structure for a module:
  - `$ tree minimal-module/`
  - 
        .
        ├── LICENSE
        ├── README.md
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf

- Modules inherit their providers from the calling configuration, so there is no need for a provider block
- Output variables defined by a module must be defined again in a root module for them to surface in the
root module that is calling another module
Example:
module outputs.tf:
```
output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}
```
The root module using that now can make that variable available from itself like so:
root module example.tf:
```
output "website_bucket_arn" {
  description = "ARN of the bucket"
  value       = module.website_s3_bucket.arn
}
```



- You can set policies explicitly like this:
```
 policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*"
            ]
        }
    ]
}
EOF
```



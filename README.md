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
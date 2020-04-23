variable "region" {
	default = "us-west-2"  # because a default was put here, this means that this value does can be used
						   #	without being explicitly set. It will use the default. If there is no
						   #	default value set, then it will need to be filled in
						   #	**These variables are filled in with terraform.tfvars files**
						   #	This file is specifically to define variables, the terraform.tfvars files
						   #	are for filling in the actual values of these files.
}

### Lists

# Declare implicitly by using brackets []
variable "cidrs" { default = [] }

# Declare explicitly with 'list'
variable "cidrs" { type = list }

### Maps

variable "amis" {
  # Here we use both explicit *and* implicit declarations for what type this variable is. You can use
  #		either seperately or both together
  type = "map"
# Map variables can act as lookup tables. If you use us-east-1, then that ami gets used. If you use
#	us-west-2 then the other ami gets used.
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-4b32be2b"
  }
}
//connections.tf
provider "aws" {
  region = "us-west-2"
  access_key="<ACCESSKEY>"   //can be set using environment variables/tfvar file
  secret_key="<SECRETKEY>"
}
resource "aws_vpc" "test_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "pf9"
  }
}

resource "aws_subnet" "pf9_subnet" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "pf9"
  }
}

resource "aws_network_interface" "pf9" {
  subnet_id   = aws_subnet.pf9_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}
variable "owner" {
  type = string
}

resource "aws_instance" "pf9" {
  ami           = "ami-005e54dee72cc1d00" # us-west-2
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.pf9.id
    device_index         = 0
  }

  tags = {
    role = "pf9user",
	owner = var.owner
	
  }
}
output "instance_ip_addr" {
  value = aws_instance.pf9.private_ip
}
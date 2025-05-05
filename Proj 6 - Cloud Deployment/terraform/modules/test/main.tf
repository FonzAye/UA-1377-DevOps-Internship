locals {
  vms = { for vm in var.vm_config : vm.name => vm }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] // AMI name contains :
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "random_id" "server" {
  for_each = local.vms

  byte_length = 4
}

resource "aws_instance" "test" {
  for_each = local.vms

  ami = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type

  tags = {
    Name = "vm-2-${random_id.server[each.key].hex}"
  }
}


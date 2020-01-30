data "aws_ami" "aws_optimized_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["137112412989"] # AWS
}

data "aws_region" "current" {}

locals {
  aws_ami_userdefined = lookup(var.amazon_optimized_amis, data.aws_region.current.name, "")
  aws_ami             = local.aws_ami_userdefined == "" ? data.aws_ami.aws_optimized_ami.id : local.aws_ami_userdefined
  service_name        = "bastion"
}

resource "aws_security_group_rule" "allow_ingress_from_admin_cidr" {
  description       = "Allow ingress from admin cidr"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = module.asg.security_group_id
  to_port           = 22
  type              = "ingress"

  cidr_blocks      = [var.admin_cidr]
  ipv6_cidr_blocks = [var.admin_ipv6_cidr]
}

resource "aws_security_group_rule" "allow_egress_to_http" {
  description       = "Allow egress to http"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = module.asg.security_group_id
  to_port           = 80
  type              = "egress"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "allow_egress_to_https" {
  description       = "Allow egress to https"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = module.asg.security_group_id
  to_port           = 443
  type              = "egress"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

data "template_file" "user_data" {
  template = file("${path.module}/template/user_data.sh")
}

module "asg" {
  //  source       = "telia-oss/asg/aws"
  source       = "../terraform-aws-asg"
  name_prefix  = "${local.service_name}-${terraform.workspace}"
  max_size     = 1
  min_size     = 0
  subnet_ids   = [var.subnet_id]
  instance_ami = local.aws_ami
  //  user_data = data.template_file.user_data.rendered

  tags = {
    Name = local.service_name
    env  = terraform.workspace
  }
}


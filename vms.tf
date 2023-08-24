resource "aws_security_group" "security_group_public" {
  name                = "sgpublic"
  description         = "sgpublic"
  vpc_id              = aws_vpc.vpc01.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "terraform-security-group-for-group-public"
  }

}

resource "aws_security_group" "security_group_private" {
  name                = "sgprivate"
  description         = "sgprivate"
  vpc_id              = aws_vpc.vpc01.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.security_group_public.id,  aws_security_group.security_group_lb.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.security_group_public.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "terraform-security-group-for-group-private"
  }

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "vm01_public" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.keypair_name
  vpc_security_group_ids      = [aws_security_group.security_group_public.id]
  subnet_id                   = aws_subnet.subnet_public.id
  tenancy                     = "default"
  associate_public_ip_address = true
  tags = {
    Name = "terraform-public-vm"
  }
  user_data                = file("./resources/haproxy-install.yml")
  depends_on = [aws_nat_gateway.nat_gateway01]
}

resource "aws_instance" "vm02_private" {
  ami                      = data.aws_ami.ubuntu.id
  instance_type            = var.instance_type
  key_name                 = var.keypair_name
  vpc_security_group_ids   = [aws_security_group.security_group_private.id]
  subnet_id		             = aws_subnet.subnet_private01.id
  private_ip               = "192.168.2.100"
  tenancy                  = "default"
  tags = {
    Name = "terraform-private-vm1"
  }
  user_data                = file("./resources/web-app-1.yml")
  depends_on = [aws_nat_gateway.nat_gateway01]
}


resource "aws_instance" "vm03_private" {
  ami                      = data.aws_ami.ubuntu.id
  instance_type            = var.instance_type
  key_name                 = var.keypair_name
  vpc_security_group_ids   = [aws_security_group.security_group_private.id]
  subnet_id		             = aws_subnet.subnet_private02.id
  private_ip               = "192.168.3.200"
  tenancy                  = "default"
  tags = {
    Name = "terraform-private-vm2"
  }
  user_data                = file("./resources/web-app-2.yml")
  depends_on = [aws_nat_gateway.nat_gateway01]
}




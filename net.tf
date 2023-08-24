resource "aws_vpc" "vpc01" {
  cidr_block = "${var.net_ip_range}"
  instance_tenancy  = "default"

  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.vpc01.id
  cidr_block = "${var.subnet_ip_range_public}"
  availability_zone = "${var.region}a"
}

# TODO merge this two aws_subnet for private subnets
resource "aws_subnet" "subnet_private01" {
  vpc_id = aws_vpc.vpc01.id
  cidr_block = "${var.subnet_ip_range_private01}"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "subnet_private02" {
  vpc_id = aws_vpc.vpc01.id
  cidr_block = "${var.subnet_ip_range_private02}"
  availability_zone = "${var.region}b"
}

resource "aws_internet_gateway" "internet_service01" {
  vpc_id = aws_vpc.vpc01.id

  tags = {
    "Name" = "terraform-internet-gateway"
  }
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc01.id
  depends_on = [aws_subnet.subnet_private01, aws_subnet.subnet_private02, aws_subnet.subnet_public]

  tags = {
    "Name" = "terraform-route-table-public"
  }
}

resource "aws_route_table_association" "route_table_attach_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route" "route01" {
  route_table_id            = aws_route_table.route_table_public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.internet_service01.id
  depends_on                = [aws_internet_gateway.internet_service01]
}

resource "aws_eip" "public_ip01" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway01" {
  subnet_id    = aws_subnet.subnet_public.id
  allocation_id = aws_eip.public_ip01.id
  depends_on   = [aws_route.route01]

  tags = {
    "Name" = "terraform-nat-gateway"
  }

}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc01.id
  depends_on = [aws_subnet.subnet_private01, aws_subnet.subnet_private02, aws_subnet.subnet_public]

  tags = {
    "Name" = "terraform-route-table-private"
  }
}

# TODO merge this two aws_route_table_association for private
resource "aws_route_table_association" "route_table_attach_private01" {
  subnet_id      = aws_subnet.subnet_private01.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route_table_association" "route_table_attach_private02" {
  subnet_id      = aws_subnet.subnet_private02.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route" "route02" {
  route_table_id = aws_route_table.route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gateway01.id
  depends_on = [aws_nat_gateway.nat_gateway01]
}


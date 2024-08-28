

# Creat VPC
resource "aws_vpc" "Pro-VPC" {
  cidr_block = var.vpc.cidr_block
  tags = {
    Name = var.vpc.Name
  }
}

# Create IGW
resource "aws_internet_gateway" "IGW" {
  tags = {
    Name = "prod IGW"
  }
}

# Create IGW attachment to Vpc
resource "aws_internet_gateway_attachment" "giw_att" {
  vpc_id              = aws_vpc.Pro-VPC.id
  internet_gateway_id = aws_internet_gateway.IGW.id
}

# Creat public subnet
resource "aws_subnet" "pub-subnets" {
  for_each                = var.public-subnet
  vpc_id                  = aws_vpc.Pro-VPC.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.value.Name
  }
}

# Create public route table
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.Pro-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "public route table"
  }
}

# Creat public subnet association
resource "aws_route_table_association" "public-rtb-assoc" {
  for_each       = aws_subnet.pub-subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-rtb.id
}

# Create private subnet
resource "aws_subnet" "private-subnets" {
  for_each                = var.private-subnet
  vpc_id                  = aws_vpc.Pro-VPC.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.zone
  map_public_ip_on_launch = false
  tags = {
    Name = each.value.Name
  }
}

# Crate Elastic IP
resource "aws_eip" "EIP_for_NAT_Gateway" {
  tags = {
    Name = "Elasic IP"
  }
}

#Create NAT Gateway for private subnet
resource "aws_nat_gateway" "NAT_Gateway" {
    allocation_id = aws_eip.EIP_for_NAT_Gateway.id
    subnet_id     = aws_subnet.pub-subnets["pub-subnet-1"].id
    tags = {
    Name = "gw NAT"
  }
}

# Create private route table
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.Pro-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_Gateway.id
  }
  tags = {
    Name = "private route table"
  }
}

# Creat private subnet association
resource "aws_route_table_association" "private-rtb-assoc" {
  for_each       = aws_subnet.private-subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private-rtb.id
}
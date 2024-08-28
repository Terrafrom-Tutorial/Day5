#Create Key Pair
resource "tls_private_key" "prodKey" {
  algorithm = "RSA"
  rsa_bits  = 1024
}

resource "local_file" "private-key" {
  filename        = "${path.root}/private_key.pem"
  content         = tls_private_key.prodKey.private_key_pem
  
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "amt.pub"
  public_key = tls_private_key.prodKey.public_key_openssh
}

resource "aws_security_group" "server_sg" {
  vpc_id = aws_vpc.Pro-VPC.id
  name   = "server-sg"
  tags = {
    Name = "server SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_all_allow" {
  security_group_id = aws_security_group.server_sg.id
  cidr_ipv4         = local.anywhere
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "egress_all_allow" {
  security_group_id = aws_security_group.server_sg.id
  cidr_ipv4         = local.anywhere
  ip_protocol       = "-1" # all protocol allow
}
#Create EC2 instance
resource "aws_instance" "server" {
  ami                    = local.selected_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.pub-subnets["pub-subnet-1"].id
  vpc_security_group_ids = [aws_security_group.server_sg.id]
  key_name               = aws_key_pair.ec2_key_pair.key_name

  tags = {
    Name = "${var.vpc.Name} Server"
  }
}



# Crate Elastic IP
resource "aws_eip" "EIP" {
  tags = {
    Name = "Elasic IP"
  }
}

resource "aws_eip_association" "att_to_ec2" {
  allocation_id = aws_eip.EIP.id
  instance_id = aws_instance.server.id
}
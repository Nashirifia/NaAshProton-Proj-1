# Configure the VPC
resource "aws_vpc" "NaAsh-Vpc-1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "NaAsh-Vpc-1"
  }
}


# Configure Public Subnet 1
resource "aws_subnet" "Public-Subnet1" {
  vpc_id     = aws_vpc.NaAsh-Vpc-1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public-Subnet1"
  }
}


# Configure Public Subnet 2
resource "aws_subnet" "Public-Subnet2" {
  vpc_id     = aws_vpc.NaAsh-Vpc-1.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Public-Subnet2"
  }
}


# Configure Private Subnet 1
resource "aws_subnet" "Private-Subnet1" {
  vpc_id     = aws_vpc.NaAsh-Vpc-1.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Private-Subnet1"
  }
}


# Configure Private Subnet 2
resource "aws_subnet" "Private-Subnet2" {
  vpc_id     = aws_vpc.NaAsh-Vpc-1.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Private-Subnet2"
  }
}


# Configure Public Route Table
resource "aws_route_table" "NaAshPublic-RT" {
  vpc_id = aws_vpc.NaAsh-Vpc-1.id

  tags = {
    Name = "NaAshPublic-RT"
  }
}


# Configure Private Route Table
resource "aws_route_table" "NaAshPrivate-RT" {
  vpc_id = aws_vpc.NaAsh-Vpc-1.id

  tags = {
    Name = "NaAshPrivate-RT"
  }
}


# Route Association For Public Subnet
resource "aws_route_table_association" "NaAshPublic-RT-Association-1" {
  subnet_id      = aws_subnet.Public-Subnet1.id
  route_table_id = aws_route_table.NaAshPublic-RT.id
}


resource "aws_route_table_association" "NaAshPublic-RT-Association-2" {
  subnet_id      = aws_subnet.Public-Subnet2.id
  route_table_id = aws_route_table.NaAshPublic-RT.id
}


# Route Association For Private Subnet
resource "aws_route_table_association" "NaAshPrivate-RT-Association-1" {
  subnet_id      = aws_subnet.Private-Subnet1.id
  route_table_id = aws_route_table.NaAshPrivate-RT.id
}


resource "aws_route_table_association" "NaAshPrivate-RT-Association-2" {
  subnet_id      = aws_subnet.Private-Subnet2.id
  route_table_id = aws_route_table.NaAshPrivate-RT.id
}

# Internet Gateway
resource "aws_internet_gateway" "NaAshIGW" {
  vpc_id = aws_vpc.NaAsh-Vpc-1.id

  tags = {
    Name = "NaAshIGW"
  }
}


# Internet Gateway Route
resource "aws_route" "NaAshIGW-Route1" {
  route_table_id            = aws_route_table.NaAshPublic-RT.id
  gateway_id                = aws_internet_gateway.NaAshIGW.id
  destination_cidr_block    = "0.0.0.0/0"
  }


# Configure Elastic IP
resource "aws_eip" "NaAshEIP" {
  vpc                       = true
  associate_with_private_ip = "10.0.3.0/24"
  depends_on                = [aws_internet_gateway.NaAshIGW]
}


# Configure Nat Gateway Internet with Public Subnet
resource "aws_nat_gateway" "NaAshNatGW" {
  allocation_id = aws_eip.NaAshEIP.id
  subnet_id     = aws_subnet.Public-Subnet1.id
  depends_on = [aws_eip.NaAshEIP]
}


# Associate Private Route Table with Nat Gateway
resource "aws_route" "NaAshNatGW-Ass-Private-RT" {
  route_table_id            = aws_route_table.NaAshPrivate-RT.id
  nat_gateway_id            = aws_nat_gateway.NaAshNatGW.id
  destination_cidr_block    = "0.0.0.0/0"
  }


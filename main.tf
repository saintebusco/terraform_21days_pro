
resource "aws_vpc" "vpc" {
  cidr_block              = var.VPC_CIDR
  instance_tenancy        = "default"
  enable_dns_hostnames    = true
  enable_dns_support =  true
  
  tags      = {
    Name    = "${var.PROJECT_NAME}-vpc"
  }
}

  
    
# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "${var.PROJECT_NAME}-igw"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# create public subnet pub-sub-1-a
resource "aws_subnet" "pub-sub-1-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.PUB_SUB_1_A_CIDR
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "pub-sub-1-a"
  }
}

# create public subnet pub-sub-2-b
resource "aws_subnet" "pub-sub-2-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.PUB_SUB_2_B_CIDR
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "pub-sub-2-b"
  }
}



# create route table and add public route
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags       = {
    Name     = "Public-RT"
  }
}

# associate public subnet pub-sub-1-a to "public route table"
resource "aws_route_table_association" "pub-sub-1-a_route_table_association" {
  subnet_id           = aws_subnet.pub-sub-1-a.id
  route_table_id      = aws_route_table.public_route_table.id
}

# associate public subnet az2 to "public route table"
resource "aws_route_table_association" "pub-sub-2-b_route_table_association" {
  subnet_id           = aws_subnet.pub-sub-2-b.id
  route_table_id      = aws_route_table.public_route_table.id
}

# create private app subnet pri-sub-3-a
resource "aws_subnet" "pri-sub-3-a" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.PRI_SUB_3_A_CIDR
  availability_zone        = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "pri-sub-3-a"
  }
}

# create private app pri-sub-4-b
resource "aws_subnet" "pri-sub-4-b" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.PRI_SUB_4_B_CIDR
  availability_zone        = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "pri-sub-4-b"
  }
}

# create private data subnet pri-sub-5-a
resource "aws_subnet" "pri-sub-5-a" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.PRI_SUB_5_A_CIDR
  availability_zone        = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "pri-sub-5-a"
  }
}

# create private data subnet pri-sub-6-b
resource "aws_subnet" "pri-sub-6-b" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.PRI_SUB_6_B_CIDR
  availability_zone        = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "pri-sub-6-b"
  }
}


resource "aws_instance" "public" {
  ami                         = "ami-0df435f331839b2d6"
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  key_name                    =  "main"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.pub-sub-1-a.id

  tags = {
    Name : "$(var.env_prefix)-puiblic"
  } 
}

resource "aws_security_group" "public" {
  name        = "$(var.env_prefix)-public"
  description = "allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description   = "ssh from public"
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  tags = {
    Name = "$(var.env_prefix)-public"
  }
}

/*resource "aws_launch_configuration" "main" {
  name_prefix     = "$(var.env_prefix)-"
  image_id        =  "ami-0df435f331839b2d6"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.public.id]
  user_data       = file("user-data.sh")
  key_name        = "main"
}

resource "aws_autoscaling_group" "main" {
  name             = var.env_prefix
  min_size         = 2
  desired_capacity = 2
  max_size         = 4

target_group_arns    = [aws_lb_target_group.main.arn]
launch_configuration = aws_launch_configuration.main.name
vpc_zone_identifier  = ["aws_subnet.pri-sub-3-a.id","aws_subnet.pri-sub-3-a.id"] 

tag {
   key                 = "name"
   value               = var.env_prefix
   propagate_at_launch = true
 }
}*/


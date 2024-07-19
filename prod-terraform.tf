provider "aws" {
  region = "us-east-1"
  access_key = "AKIAQ3EGVH3YS2JRDNJO"
  secret_key = "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"
}

resource "aws_vpc" "shubh_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc9"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.shubh_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mysubnet9"
  }
}

resource "aws_internet_gateway" "mygw" {
  vpc_id = aws_vpc.shubh_vpc.id

  tags = {
    Name = "mygw9"
  }
}

resource "aws_route_table" "myrt9" {
  vpc_id = aws_vpc.shubh_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygw.id
  }

  tags = {
    Name = "myrt9"
  }
}

resource "aws_route_table_association" "myrta9" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myrt9.id
}

resource "aws_security_group" "mysg9" {
  name        = "mysg9"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.shubh_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mysg9"
  }
}

resource "aws_instance" "instance9" {
  ami                         = "ami-0f58b397bc5c1f2e8"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.mysubnet.id
  vpc_security_group_ids      = [aws_security_group.mysg9.id]
  key_name                    = "jenkins"  # Ensure this key pair exists
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
   
  EOF
  tags = {
    Name = "prod-server"
  }
}

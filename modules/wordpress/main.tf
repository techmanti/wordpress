provider "aws" {

  region                   = var.region
  shared_credentials_files = [var.shared_credentials_file]
  profile                  = "default"
}


# create vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block           = var.VPC_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"


}

# first public subnet EC2
resource "aws_subnet" "prod-subnet-public-1" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = var.subnet1_cidr
  map_public_ip_on_launch = "true" //public subnet 
  availability_zone       = var.AZ1

}

# second public subnet EC2
resource "aws_subnet" "prod-subnet-public-2" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = var.subnet4_cidr
  map_public_ip_on_launch = "true" 
  availability_zone       = var.AZ2

}

# first private subnet RDS
resource "aws_subnet" "prod-subnet-private-1" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = var.subnet2_cidr
  map_public_ip_on_launch = "false" //private subnet
  availability_zone       = var.AZ2

}

# second private subnet RDS
resource "aws_subnet" "prod-subnet-private-2" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = var.subnet3_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.AZ3

}


# create IGW( Internet Gateway) 
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

}

# route table
resource "aws_route_table" "prod-public-crt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }


}


# associeation route table to public subnet
resource "aws_route_table_association" "prod-crta-public-subnet-1" {
  subnet_id      = aws_subnet.prod-subnet-public-1.id
  route_table_id = aws_route_table.prod-public-crt.id
}



//security group for EC2
resource "aws_security_group" "ec2_allow_rule" {

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "allow ssh,http,https"
  }
}


# Security group for RDS
resource "aws_security_group" "RDS_allow_rule" {
  vpc_id = aws_vpc.prod-vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ec2_allow_rule.id}"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow ec2"
  }

}

# create RDS Subnet group
resource "aws_db_subnet_group" "RDS_subnet_grp" {
  subnet_ids = ["${aws_subnet.prod-subnet-private-1.id}", "${aws_subnet.prod-subnet-private-2.id}"]
}

# create RDS instance
resource "aws_db_instance" "wordpressdb" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.RDS_subnet_grp.id
  vpc_security_group_ids = ["${aws_security_group.RDS_allow_rule.id}"]
  db_name                = var.database_name
  username               = var.database_user
  password               = var.database_password
  skip_final_snapshot    = true

  lifecycle {
    ignore_changes = [password]
  }
}

data "template_file" "user_data" {
  template = var.IsUbuntu ? file("${path.module}/userdata_ubuntu.tpl") : file("${path.module}/user_data.tpl")
  vars = {
    db_username      = var.database_user
    db_user_password = var.database_password
    db_name          = var.database_name
    db_RDS           = aws_db_instance.wordpressdb.endpoint
  }
}


# create EC2
resource "aws_instance" "wordpressec2" {
  ami                    = var.aws_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.prod-subnet-public-1.id
  vpc_security_group_ids = ["${aws_security_group.ec2_allow_rule.id}"]
  user_data              = data.template_file.user_data.rendered
  key_name               = aws_key_pair.mykey-pair.id
  tags = {
    Name = "Wordpress.web"
  }
  volume_tags = {
    "backup" = "True"
  }

  root_block_device {
    volume_size = var.root_volume_size

  }

  # RDS > EC2 
  depends_on = [aws_db_instance.wordpressdb]
}

// sends your public key to the instance
resource "aws_key_pair" "mykey-pair" {
  key_name   = "mykey-pair"
  public_key = file(var.PUBLIC_KEY_PATH)
}

# create Elastic IP for EC2
resource "aws_eip" "eip" {
  instance = aws_instance.wordpressec2.id

}

resource "null_resource" "Wordpress_Installation_Waiting" {
  triggers = {
    ec2_id       = aws_instance.wordpressec2.id,
    rds_endpoint = aws_db_instance.wordpressdb.endpoint

  }
  connection {
    type        = "ssh"
    user        = var.IsUbuntu ? "ubuntu" : "ec2-user"
    private_key = file(var.PRIV_KEY_PATH)
    host        = aws_eip.eip.public_ip
  }


  provisioner "remote-exec" {
    inline = ["sudo tail -f -n0 /var/log/cloud-init-output.log| grep -q 'WordPress Installed'"]

  }
}

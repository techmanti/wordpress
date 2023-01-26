

module "aws_wordpress" {
  source                  = "./modules/wordpress"
  database_name           = "wordpresstechman_db" // database name
  database_user           = "tmroot"              //database username
  database_password       = var.database_password        //password for user database
  shared_credentials_file = "~/.aws/credentials"  //access key and Secret key file location
  region                  = "us-east-2"           //ohio lest eua
  IsUbuntu                = true                  // true for ubuntu -false for linux 2  //boolean type
  // zona de disponibilidade CIDR
  AZ1              = "us-east-2a"       // for EC2
  AZ2              = "us-east-2b"       //for RDS 
  AZ3              = "us-east-2c"       //for RDS
  VPC_cidr         = "10.0.0.0/16"      // VPC CIDR
  subnet1_cidr     = "10.0.1.0/24"      // public Subnet for EC2
  subnet2_cidr     = "10.0.2.0/24"      //private Subnet for RDS
  subnet3_cidr     = "10.0.3.0/24"      //private subnet for RDS
  PUBLIC_KEY_PATH  = "./mykey-pair.pub" // key public
  PRIV_KEY_PATH    = "./mykey-pair"
  instance_type    = "t2.micro"    //type of instance
  instance_class   = "db.t2.micro" //type of RDS Instance
  root_volume_size = 22
}
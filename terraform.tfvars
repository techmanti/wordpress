database_name           = "wordpresstechman_db"
database_user           = "tmroot"
shared_credentials_file = "~/.aws/credentials"
region                  = "us-east-2" //ohio lest eua
IsUbuntu                = true
AZ1                     = "us-east-2a"
AZ2                     = "us-east-2b"
AZ3                     = "us-east-2c"
VPC_cidr                = "10.0.0.0/16"
subnet1_cidr            = "10.0.1.0/24"
subnet2_cidr            = "10.0.2.0/24"
subnet3_cidr            = "10.0.3.0/24"
subnet4_cidr            = "10.0.4.0/24"
PUBLIC_KEY_PATH         = "./mykey-pair.pub"
PRIV_KEY_PATH           = "./mykey-pair"
instance_type           = "t2.micro"
instance_class          = "db.t2.micro"
root_volume_size        = 22
aws_ami                 = "ami-0cb81cb394fc2e305"
domain_name             = "techman.sh"
record_name             = "www"
alternative_name        = "*.techman.sh"
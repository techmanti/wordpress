output "ec2_wp_public_ip" {
  value = "http://${aws_instance.wordpressec2.public_ip}"
} 

output "ec2_security_group_id" {
  value = aws_security_group.ec2_allow_rule.id
}

output "public_subnet_az1_id" {
  value = aws_subnet.prod-subnet-public-1.id
}

output "public_subnet_az2_id" {
  value = aws_subnet.prod-subnet-public-2.id
}

output "vpc_id" {
  value = aws_vpc.prod-vpc.id  
}

output "instance_id" {
  value = aws_instance.wordpressec2.id
}
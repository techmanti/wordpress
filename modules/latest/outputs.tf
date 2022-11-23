output "ec2_wp_public_ip" {
  value = "http://${aws_instance.wordpressec2.public_ip}"
} 
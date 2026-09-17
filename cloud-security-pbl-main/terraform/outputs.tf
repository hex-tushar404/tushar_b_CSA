output "vpc_id" {
  description = "ID of the Cloud Security VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "web_security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web.id
}

output "s3_bucket_name" {
  description = "Name of the application data S3 bucket"
  value       = aws_s3_bucket.application_data.id
}

output "ec2_iam_role_name" {
  description = "IAM role assigned to EC2"
  value       = aws_iam_role.ec2_s3_role.name
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_instance_id" {
  description = "ID of the EC2 web server"
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 web server"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 web server"
  value       = aws_instance.web.public_dns
}
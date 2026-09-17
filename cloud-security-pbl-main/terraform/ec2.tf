# ==============================
# EC2 Linux Web Server
# ==============================

resource "aws_instance" "web" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  key_name = aws_key_pair.cloud_security.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash

              apt-get update -y
              apt-get install -y nginx

              systemctl enable nginx
              systemctl start nginx

              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Cloud Security PBL</title>
              </head>
              <body>
                  <h1>Cloud Security PBL Web Server</h1>
                  <p>EC2 Linux server successfully deployed.</p>
                  <p>Managed using Terraform.</p>
              </body>
              </html>
              HTML
              EOF

  tags = {
    Name = "cloud-security-web-server"
  }
}
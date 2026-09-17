resource "aws_key_pair" "cloud_security" {
  key_name   = "cloud-security-pbl-key"
  public_key = file("~/.ssh/cloud-security-pbl.pub")

  tags = {
    Name    = "cloud-security-pbl-key"
    Project = "Cloud-Security-PBL"
  }
}
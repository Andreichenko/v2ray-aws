#Create SG for allowing traffic on Xray ports in eu-central-1
resource "aws_security_group" "xray-sg" {
  provider    = aws.region-common
  name        = "xray-sg"
  description = "Allow in traffic for all ports"
  vpc_id      = aws_vpc.vpc-central-1.id

  ingress {
    description = "Allow all in traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all out traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

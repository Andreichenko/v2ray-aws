#Create SG for allowing TCP/8080 from all and tcp/22 from some ip in eu-central-1
resource "aws_security_group" "v2ray-sg" {
  provider    = aws.region-common
  name        = "v2ray-sg"
  description = "Allow in"
  vpc_id      = aws_vpc.vpc-central-1.id

  ingress {
    description = "Allow all in"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all in"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

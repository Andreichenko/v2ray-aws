output "aws_subnet_1" {
  value       = aws_subnet.subnet-1a.id
  description = "Subnet id"
}

output "aws_subnet_2" {
  value       = aws_subnet.subnet-1b.id
  description = "Subnet id"
}

output "aws_subnet_3" {
  value       = aws_subnet.subnet-1c.id
  description = "Subnet id for v2ray"
}

output "vpc_common" {
  value       = aws_vpc.vpc-central-1.cidr_block
  description = "CIDR"
}

output "v2ray-server-public-ip" {
  value       = aws_instance.v2ray-server.public_ip
  description = "public IP"
}

output "route-table" {
  value = aws_route_table.public-routes.id
}

output "route-table-values" {
  value = aws_route_table.public-routes.route
}

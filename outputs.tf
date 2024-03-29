output "aws_subnet_1" {
  value       = aws_subnet.subnet-1a.id
  description = "Subnet id primary subnet for vault regarding secrets"
}

output "aws_subnet_2" {
  value       = aws_subnet.subnet-1b.id
  description = "Subnet id second subnet for vault regarding secret credentials"
}

output "aws_subnet_3" {
  value       = aws_subnet.subnet-1c.id
  description = "Subnet id for v2ray instance in eu-central-1"
}

output "vpc_common" {
  value       = aws_vpc.vpc-central-1.cidr_block
  description = "CIDR for second subnet in eu-central-1"
}

output "v2ray-server-public-ip" {
  value       = aws_instance.v2ray-server.public_ip
  description = "public IP v2ray server"
}

output "route-table" {
  value = aws_route_table.public-routes.id
}

output "route-table-values" {
  value = aws_route_table.public-routes.route
}

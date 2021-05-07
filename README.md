## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | >=3.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws.region-common | >=3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance\_type | The main type of instance in this case | `string` | `"t2.micro"` | no |
| profile | The main profile for aws credentials | `string` | `"default"` | no |
| region-common | The main region | `string` | `"eu-central-1"` | no |
| vpc\_cidr\_block | The IPv4 CIDR block of the VPC | `string` | `"10.0.0.0/16"` | no |
| vpc\_enable\_dns\_hostnames | Should instances in the VPC get public DNS hostnames? | `bool` | `false` | no |
| vpc\_enable\_dns\_support | Should the DNS resolution be supported? | `bool` | `false` | no |
| vpc\_name | The Name of the VPC | `string` | `"v2ray VPC"` | no |
| vpc\_should\_be\_created | Should the VPC be created? | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_subnet\_1 | Subnet id |
| aws\_subnet\_2 | Subnet id |
| aws\_subnet\_3 | Subnet id |
| route-table | n/a |
| route-table-values | n/a |
| v2ray-server-public-ip | public IP |
| vpc\_common | CIDR |


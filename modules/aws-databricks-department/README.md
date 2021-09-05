E2 design pattern, that creates restricted S3 bucket with EC2 instance profile to access data, registers it within Databricks, attaches it to cluster policy and allows usage to this group.

Per-department "Shared Autoscaling" cluster is created and basic notebooks are added as well.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_zone | n/a | `any` | n/a | yes |
| crossaccount\_role\_name | n/a | `any` | n/a | yes |
| databricks\_workspace\_host | n/a | `any` | n/a | yes |
| databricks\_workspace\_token | n/a | `any` | n/a | yes |
| department | n/a | `any` | n/a | yes |
| force\_destroy | n/a | `any` | n/a | yes |
| name | n/a | `any` | n/a | yes |
| prefix | n/a | `any` | n/a | yes |
| region | n/a | `any` | n/a | yes |
| tags | Tags applied to all resources created | `map(string)` | n/a | yes |
| versioning | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket | n/a |
| reader\_policy\_arn | n/a |


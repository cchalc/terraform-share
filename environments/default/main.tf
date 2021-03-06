module "multiworkspace_demo" {
  source = "../../modules/azure-vnet-injection"
  cidr   = "10.31.0.0/16"
}

output "workspace_url" {
  value = module.multiworkspace_demo.workspace_url
}

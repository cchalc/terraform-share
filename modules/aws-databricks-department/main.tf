/**
 * E2 design pattern, that creates restricted S3 bucket with EC2 instance profile to access data, registers it within Databricks, attaches it to cluster policy and allows usage to this group.
 * 
 * Per-department "Shared Autoscaling" cluster is created and basic notebooks are added as well.
 */
variable "databricks_workspace_host" {}
variable "databricks_workspace_token" {}
variable "crossaccount_role_name" {}
variable "name" {}
variable "department" {}
variable "prefix" {}
variable "aws_zone" {}
variable "region" {}
variable "force_destroy" {}
variable "versioning" {}
variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources created"
}

module "bucket" {
  source                     = "./restricted-bucket"
  region                     = var.region
  aws_zone                   = var.aws_zone
  databricks_workspace_host  = var.databricks_workspace_host
  databricks_workspace_token = var.databricks_workspace_token
  crossaccount_role_name     = var.crossaccount_role_name
  department                 = var.department
  name                       = var.name
  prefix                     = var.prefix
  tags                       = var.tags
  force_destroy              = var.force_destroy
  versioning                 = var.versioning
  skip_validation            = true
}

resource "databricks_group" "this" {
  display_name               = var.department
  // we disallow cluster create to group, but allow it through policy
  allow_cluster_create       = false
  allow_instance_pool_create = false
}

resource "databricks_group_instance_profile" "this" {
  group_id = databricks_group.this.id
  instance_profile_id = module.bucket.databricks_instance_profile_id
}

resource "databricks_cluster_policy" "fair_use" {
  name = "${var.department} Cluster Policy"
  definition = jsonencode({
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
    },
    "spark_conf.spark.databricks.cluster.profile" : {
      "type" : "fixed",
      "value" : "serverless",
      "hidden" : true
    },
    "instance_pool_id" : {
      "type" : "forbidden",
      "hidden" : true
    },
    "spark_version" : {
       "type" : "regex",
       "pattern" : "6\\.[0-9]+\\.x-scala.*",
       "defaultValue" : "6.6.x-scala2.11"
    },
//    "node_type_id" : {
//      "type" : "whitelist",
//      "values" : [
//        "i3.xlarge",
//        "i3.2xlarge",
//        "i3.4xlarge"
//      ],
//      "defaultValue" : "i3.xlarge"
//    },
    "driver_node_type_id" : {
      "type" : "fixed",
      "value" : "i3.2xlarge",
      "hidden" : true
    },
    "autoscale.min_workers" : {
      "type" : "fixed",
      "value" : 1,
      "hidden" : true
    },
    "aws_attributes.zone_id" : {
      "type" : "fixed",
      "value" : var.aws_zone,
      "hidden" : true
    },
    "aws_attributes.instance_profile_arn" : {
      "type" : "fixed",
      "value" : module.bucket.instance_profile_arn,
      "hidden" : true
    },
    "custom_tags.Team" : {
      "type" : "fixed",
      "value" : var.department
    }
  })
}

resource "databricks_permissions" "can_use_instance_profile" {
  cluster_policy_id = databricks_cluster_policy.fair_use.id
  access_control {
    group_name       = databricks_group.this.display_name
    permission_level = "CAN_USE"
  }
}

resource "databricks_cluster" "team_shared_autoscaling" {
  cluster_name            = "${var.department} Shared Autoscaling"
  spark_version           = "6.6.x-scala2.11"
  node_type_id            = "i3.xlarge"
  autotermination_minutes = 20

  autoscale {
    min_workers = 1
    max_workers = 10
  }

  aws_attributes {
    instance_profile_arn = module.bucket.instance_profile_arn
    availability         = "SPOT"
    zone_id              = var.aws_zone
  }

  custom_tags = merge(var.tags, {
    Team = var.department
  })
}

resource "databricks_permissions" "can_use_team_cluster" {
  cluster_id = databricks_cluster.team_shared_autoscaling.id
  access_control {
    group_name       = databricks_group.this.display_name
    permission_level = "CAN_MANAGE"
  }
}

resource "databricks_notebook" "init_database_notebook" {
  content = base64encode(templatefile("${path.module}/init.py", {
    db_name = var.name
    bucket  = module.bucket.bucket
  }))
  path      = "/${var.department}/Init"
  overwrite = true
  mkdirs    = true
  language  = "PYTHON"
  format    = "SOURCE"
}

output "bucket" {
  value = module.bucket.bucket
}

output "reader_policy_arn" {
  value = module.bucket.reader_policy_arn
}
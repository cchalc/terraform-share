/**
 * Extendable enterprisse cluster policy module, that customers should tune to their own use-cases
 */
variable "team" {
  description = "Team that performs the work"
}

variable "policy_overrides" {
  description = "Cluster policy overrides"
}

locals {
  default_policy = {
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
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
    "spark_conf.spark.databricks.io.cache.enabled": {
      "type": "fixed",
      "value": "true"
    },
    "autotermination_minutes": {
      "type": "fixed",
      "value": 20,
      "hidden": true
    },
    "custom_tags.Team" : {
      "type" : "fixed",
      "value" : var.team
    }
  }
}

resource "databricks_cluster_policy" "fair_use" {
  name = "${var.team} cluster policy"
  definition = jsonencode(merge(local.default_policy, var.policy_overrides))
}

resource "databricks_permissions" "can_use_instance_profile" {
  cluster_policy_id = databricks_cluster_policy.fair_use.id
  access_control {
    group_name       = var.team
    permission_level = "CAN_USE"
  }
}
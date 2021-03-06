/**
 * Samples of cluster policies
 */
terraform {
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
    }
  }
}

variable "default_policy" {
  default = {}
}

resource "databricks_cluster_policy" "job-policy" {
  name       = "Job Only Policy"
  definition = jsonencode(merge(var.default_policy,
  {
    "cluster_type" : {
      "type" : "fixed",
      "value" : "job"
    },
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 100
    },
    "instance_pool_id" : {
      "type" : "forbidden",
      "hidden" : "true"
    },
    "num_workers" : {
      "type" : "range",
      "minValue" : 1
    },
    "node_type_id" : {
      "type" : "regex",
      "pattern" : "^Standard_L(8|16)s_v2$"
    },
    "driver_node_type_id" : {
      "type" : "regex",
      "pattern" : "^Standard_L(8|16)s_v2$"
    },
    "spark_version" : {
      "type" : "regex",
      "pattern" : "6.[0-9].x-scala.*"
    },
    "custom_tags.team" : {
      "type" : "fixed",
      "value" : "data_platform"
    }
  }
  ))
}

resource "databricks_cluster_policy" "adhoc-policy" {
  name       = "Adhoc Policy"
  definition = jsonencode(merge(var.default_policy,
  {
    "cluster_type" : {
      "type" : "fixed",
      "value" : "all-purpose"
    },
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 200
    },
    "instance_pool_id" : {
      "type" : "forbidden",
      "hidden" : "true"
    },
    "node_type_id" : {
      "type" : "regex",
      "pattern" : "^Standard_(DS4|DS3)_v2$"
    },
    "driver_node_type_id" : {
      "type" : "regex",
      "pattern" : "^Standard_(DS4|DS3)_v2$"
    },
    "autoscale.min_workers" : {
      "type" : "fixed",
      "value" : 1
    },
    "autoscale.max_workers" : {
      "type" : "fixed",
      "value" : 10,
      "defaultValue" : 5
    }
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 60,
      "hidden" : false
    },
    "spark_version" : {
      "type" : "regex",
      "pattern" : "7.[0-9].x-scala.*"
    },
    "custom_tags.team" : {
      "type" : "fixed",
      "value" : "analysts"
    }
  }
  ))
}

resource "databricks_cluster_policy" "hc-passthrough-policy" {
  name       = "High Concurrency Passthrough Policy"
  definition = jsonencode(merge(var.default_policy,
  {
    "spark_conf.spark.databricks.passthrough.enabled" : {
      "type" : "fixed",
      "value" : "true"
    },
    "spark_conf.spark.databricks.repl.allowedLanguages" : {
      "type" : "fixed",
      "value" : "python,sql"
    },
    "spark_conf.spark.databricks.cluster.profile" : {
      "type" : "fixed",
      "value" : "serverless"
    },
    "spark_conf.spark.databricks.pyspark.enableProcessIsolation" : {
      "type" : "fixed",
      "value" : "true"
    },
    "custom_tags.ResourceClass" : {
      "type" : "fixed",
      "value" : "Serverless"
    }
  }
  ))
}

resource "databricks_cluster_policy" "ml-policy" {
  name       = "Machine Learning Policy"
  definition = jsonencode(merge(var.default_policy,
  {
    "cluster_type" : {
      "type" : "fixed",
      "value" : "all-purpose"
    },
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 200
    },
    "instance_pool_id" : {
      "type" : "forbidden",
      "hidden" : "true"
    },
    "node_type_id" : {
      "type" : "regex",
      "pattern" : "^Standard_L(8|16)s_v2$"
    },
    "driver_node_type_id" : {
      "type" : "regex",
      "pattern" : "^Standard_L(8|16)s_v2$"
    },
    "autoscale.min_workers" : {
      "type" : "fixed",
      "value" : 1
    },
    "autoscale.max_workers" : {
      "type" : "fixed",
      "value" : 20,
      "defaultValue" : 5
    }
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 60,
      "hidden" : true
    },
    "spark_version" : {
      "type" : "regex",
      "pattern" : "7.[0-2].x-cpu-ml-scala.*"
    },
    "custom_tags.team" : {
      "type" : "fixed",
      "value" : "data_science"
    }
  }
  ))
}

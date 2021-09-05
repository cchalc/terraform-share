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
variable "skip_validation" { default = false }

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources created"
}

module "this" {
  source        = "../../aws-databricks-bucket"
  name          = "${var.prefix}-${var.name}"
  region        = var.region
  force_destroy = var.force_destroy
  versioning    = var.versioning
  tags          = var.tags
}

module "instance_profile" {
  source = "../instance-profile"
  name = "${var.prefix}-${var.name}"
  description = "AWS IAM role for ${var.department} team"
  databricks_workspace_host = var.databricks_workspace_host
  databricks_workspace_token = var.databricks_workspace_token
  crossaccount_role_name = var.crossaccount_role_name
  skip_validation = var.skip_validation
  tags = var.tags
}

data "aws_iam_policy_document" "bucket_access" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:PutObject",
    "s3:DeleteObject"]
    resources = ["${module.this.arn}/*",
    module.this.arn]
  }
}

resource "aws_iam_role_policy" "team_bucket_access" {
  name   = "${var.prefix}-${var.name}-s3-access"
  role   = module.instance_profile.role_for_s3_access_id
  policy = data.aws_iam_policy_document.bucket_access.json
}

data "aws_iam_policy_document" "read_only" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetBucketLocation"]
    resources = ["${module.this.arn}/*",
      module.this.arn]
  }
}

resource "aws_iam_policy" "read_only" {
  name = "${var.prefix}-${var.name}-s3-ro"
  policy = data.aws_iam_policy_document.read_only.json
  description = "Grants read-only permissions to ${module.this.bucket} bucket"
}

output "bucket" {
  value = module.this.bucket
}

output "instance_profile_arn" {
  value = module.instance_profile.instance_profile_arn
}

output "databricks_instance_profile_id" {
  value = module.instance_profile.databricks_instance_profile_id
}

output "reader_policy_arn" {
  value = aws_iam_policy.read_only.arn
}
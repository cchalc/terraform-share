variable "databricks_workspace_host" {}
variable "databricks_workspace_token" {}
variable "crossaccount_role_name" {}
variable "description" {}
variable "name" {}
variable "tags" {}
variable "skip_validation" { default = false }

data "aws_iam_policy_document" "assume_role_for_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "role_for_s3_access" {
  name               = "${var.name}-ec2-role-for-s3"
  description        = var.description
  assume_role_policy = data.aws_iam_policy_document.assume_role_for_ec2.json
  tags               = var.tags
}

data "aws_iam_policy_document" "pass_role_for_s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.role_for_s3_access.arn]
  }
}

resource "aws_iam_policy" "pass_role_for_s3_access" {
  name   = "${var.name}-pass-role-for-s3-access"
  path   = "/"
  policy = data.aws_iam_policy_document.pass_role_for_s3_access.json
}

resource "aws_iam_role_policy_attachment" "cross_account" {
  policy_arn = aws_iam_policy.pass_role_for_s3_access.arn
  role       = var.crossaccount_role_name
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.role_for_s3_access.name
}

resource "databricks_instance_profile" "instance_profile" {
  instance_profile_arn = aws_iam_instance_profile.instance_profile.arn
  skip_validation      = var.skip_validation
}

output "role_for_s3_access_id" {
  value = aws_iam_role.role_for_s3_access.id
}

output "role_for_s3_access_name" {
  value = aws_iam_role.role_for_s3_access.name
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.instance_profile.arn
}

output "databricks_instance_profile_id" {
  value = databricks_instance_profile.instance_profile.id
}
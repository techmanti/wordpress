resource "aws_backup_vault" "backup_vault" {
  name = "wp_backup_vault"
}

resource "aws_backup_plan" "backup_plan" {
  name = "wp_backup_plan"
  rule {
    rule_name         = "wp_backup_rule"
    target_vault_name = "wp_backup_vault"
    schedule          = "cron(0 12 * * ? *)"
    lifecycle {
      delete_after = 7 # delete after 7 days
    }
  }
}

resource "aws_iam_role" "default" {
  name               = "DefaultBackupRole"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.default.name
}

resource "aws_backup_selection" "backup_selection" {
  iam_role_arn = aws_iam_role.default.arn
  name         = "tf_example_backup_selection"
  plan_id      = aws_backup_plan.backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "True"
  }
}
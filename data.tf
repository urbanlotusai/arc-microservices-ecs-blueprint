# ── Account identity ──────────────────────────────────────────────────────────
data "aws_caller_identity" "current" {}

# ── KMS key policy ────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "AllowAccountRoot"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

# ── Private subnets ───────────────────────────────────────────────────────────
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [module.network.vpc_id]
  }
  tags = {
    Type = "private"
  }
  depends_on = [module.network]
}

# ── Public subnets (for ALB) ──────────────────────────────────────────────────
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [module.network.vpc_id]
  }
  tags = {
    Type = "public"
  }
  depends_on = [module.network]
}

module "waf" {
  source  = "sourcefuse/arc-waf/aws"
  version = "1.0.6"

  web_acl_name              = var.web_acl_name
  web_acl_default_action    = var.web_acl_default_action
  web_acl_scope             = var.web_acl_scope
  web_acl_visibility_config = var.web_acl_visibility_config
  web_acl_rules             = var.web_acl_rules

  tags = var.tags
}

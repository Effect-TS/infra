locals {
  owners = [
    "gcanti",
    "IMax153",
    "mikearnaldi",
    "schickling"
  ]
  members = [
    "0x706b",
    "mattiamanzati",
    "patroza",
    "pigoz",
    "qlonik",
    "r-cyr",
    "sledorze",
    "tim-smart",
    "tstelzer",
    "wesselvdv"
  ]
}

resource "github_organization_settings" "effect_ts" {
  name             = "Effect"
  description      = "A set of libraries to write better TypeScript"
  billing_email    = "ma@matechs.com"
  blog             = "https://www.effect.website"
  email            = "ma@matechs.com"
  twitter_username = "EffectTS_"
  location         = "London"

  dependabot_alerts_enabled_for_new_repositories           = false
  dependency_graph_enabled_for_new_repositories            = false
  dependabot_security_updates_enabled_for_new_repositories = false

  members_can_create_repositories          = true
  members_can_create_public_repositories   = true
  members_can_create_private_repositories  = false
  members_can_create_internal_repositories = false
  members_can_fork_private_repositories    = false

  members_can_create_pages         = true
  members_can_create_private_pages = false
  members_can_create_public_pages  = true

  default_repository_permission = "write"
  has_organization_projects     = true
  has_repository_projects       = true
  web_commit_signoff_required   = false

  advanced_security_enabled_for_new_repositories               = false
  secret_scanning_enabled_for_new_repositories                 = false
  secret_scanning_push_protection_enabled_for_new_repositories = false
}

resource "github_membership" "owner" {
  for_each = toset(local.owners)

  username = each.value
  role     = "admin"
}

resource "github_membership" "member" {
  for_each = toset(local.members)

  username = each.value
  role     = "member"
}
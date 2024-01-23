module "github_repository" {
  source                  = "../modules/github_repository"
  for_each                = var.repositories
  name                    = each.key
  description             = each.value.description
  topics                  = each.value.topics
  homepage_url            = each.value.homepage_url
  visibility              = each.value.visibility
  collaborators           = each.value.collaborators
  pages                   = each.value.pages
  has_discussions         = each.value.has_discussions
  is_archived             = each.value.is_archived
  allow_squash_merge      = each.value.allow_squash_merge
  allow_rebase_merge      = each.value.allow_rebase_merge
  branch_protection_rules = each.value.branch_protection_rules
}

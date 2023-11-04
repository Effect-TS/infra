module "github_repository" {
  source          = "../modules/github_repository"
  for_each        = var.repositories
  name            = each.key
  description     = each.value.description
  topics          = each.value.topics
  homepage_url    = each.value.homepage_url
  visibility      = each.value.visibility
  collaborators   = each.value.collaborators
  has_discussions = each.value.has_discussions
  has_pages       = each.value.has_pages
  is_archived     = each.value.is_archived
}

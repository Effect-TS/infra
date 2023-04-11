resource "github_repository" "repository" {
  for_each = var.repositories

  name                        = each.key
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_squash_merge          = true
  delete_branch_on_merge      = true
  description                 = each.value.description
  has_downloads               = true
  has_issues                  = true
  has_projects                = true
  has_wiki                    = each.value.visibility == "public"
  homepage_url                = try(each.value.homepage_url, "")
  squash_merge_commit_message = "BLANK"
  squash_merge_commit_title   = "PR_TITLE"
  topics                      = each.value.topics
  visibility                  = each.value.visibility

  dynamic "pages" {
    for_each = each.value.enable_pages ? [1] : []

    content {
      source {
        branch = var.default_branch
        path   = "/docs"
      }
    }
  }
}

resource "github_branch" "main" {
  for_each = github_repository.repository

  branch     = var.default_branch
  repository = each.value.name
}

resource "github_branch_default" "main" {
  for_each = github_repository.repository

  branch     = var.default_branch
  repository = each.value.name
}

resource "github_branch_protection" "main" {
  for_each = {
    for repository in github_repository.repository :
    repository.name => repository.node_id if repository.visibility == "public"
  }

  repository_id           = each.value
  pattern                 = var.default_branch
  enforce_admins          = true
  required_linear_history = true

  required_status_checks {
    strict   = true
    contexts = null
  }

  required_pull_request_reviews {
    required_approving_review_count = 0
  }
}

resource "github_repository_collaborators" "collaborators" {
  for_each = var.repositories

  repository = each.key

  dynamic "user" {
    for_each = each.value.collaborators

    content {
      username   = user.value.username
      permission = user.value.permission
    }
  }
}

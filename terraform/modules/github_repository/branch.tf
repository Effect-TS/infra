resource "github_branch" "main" {
  branch     = var.default_branch
  repository = github_repository.repository.name
}

resource "github_branch_default" "main" {
  branch     = var.default_branch
  repository = github_repository.repository.name
}

resource "github_branch_protection" "main" {
  # Branch protection can only be enabled on private repositories if using a
  # paid GitHub plan
  count = var.visibility == "public" ? 1 : 0

  repository_id           = github_repository.repository.node_id
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
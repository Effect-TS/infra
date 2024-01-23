resource "github_branch" "main" {
  branch     = var.default_branch
  repository = github_repository.repository.name
}

resource "github_branch_default" "main" {
  branch     = var.default_branch
  repository = github_repository.repository.name
}

resource "github_branch_protection" "rules" {
  # Branch protection can only be enabled on private repositories if using a
  # paid GitHub plan
  for_each = var.visibility == "public" ? local.branch_protection_rules : tomap({})

  repository_id                   = github_repository.repository.node_id
  pattern                         = each.key
  allows_deletions                = try(each.value.allows_deletions, false)
  allows_force_pushes             = try(each.value.allows_force_pushes, false)
  blocks_creations                = try(each.value.blocks_creations, false)
  enforce_admins                  = try(each.value.enforce_admins, false)
  lock_branch                     = try(each.value.lock_branch, false)
  require_signed_commits          = try(each.value.require_signed_commits, false)
  require_conversation_resolution = try(each.value.require_conversation_resolution, false)
  push_restrictions               = try(each.value.push_restrictions, [])
  force_push_bypassers            = try(each.value.force_push_bypassers, [])
  required_linear_history         = try(each.value.required_linear_history, false)

  dynamic "required_pull_request_reviews" {
    for_each = each.value.required_pull_request_reviews != null ? [1] : []
    content {
      dismiss_stale_reviews           = try(each.value.required_pull_request_reviews.dismiss_stale_reviews, false)
      dismissal_restrictions          = try(each.value.required_pull_request_reviews.dismissal_restrictions, [])
      restrict_dismissals             = try(each.value.required_pull_request_reviews.restrict_dismissals, false)
      pull_request_bypassers          = try(each.value.required_pull_request_reviews.pull_request_bypassers, [])
      require_code_owner_reviews      = try(each.value.required_pull_request_reviews.require_code_owner_reviews, false)
      required_approving_review_count = try(each.value.required_pull_request_reviews.required_approving_review_count, null)
      require_last_push_approval      = try(each.value.required_pull_request_reviews.require_last_push_approval, false)
    }
  }

  dynamic "required_status_checks" {
    for_each = each.value.required_status_checks != null ? [1] : []
    content {
      strict   = try(each.value.required_status_checks.strict, false)
      contexts = try(each.value.required_status_checks.contexts, [])
    }
  }
}


# resource "github_branch_protection" "next-release" {
#   # Branch protection can only be enabled on private repositories if using a
#   # paid GitHub plan
#   count = var.visibility == "public" && var.has_release_branches ? 1 : 0

#   repository_id           = github_repository.repository.node_id
#   pattern                 = "next-*"
#   enforce_admins          = true
#   required_linear_history = false
#   allows_deletions        = false
#   allows_force_pushes     = true
#   blocks_creations        = false

#   required_status_checks {
#     strict   = true
#     contexts = null
#   }

#   required_pull_request_reviews {
#     required_approving_review_count = 0
#   }
# }

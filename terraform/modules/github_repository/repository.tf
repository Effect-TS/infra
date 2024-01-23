resource "github_repository" "repository" {
  name         = var.name
  description  = var.description
  topics       = var.topics
  homepage_url = var.homepage_url
  visibility   = var.visibility

  allow_merge_commit          = var.allow_merge_commit
  allow_rebase_merge          = var.allow_rebase_merge
  allow_squash_merge          = var.allow_squash_merge
  delete_branch_on_merge      = var.delete_branch_on_merge
  squash_merge_commit_message = "BLANK"
  squash_merge_commit_title   = "PR_TITLE"

  archived        = var.is_archived
  has_discussions = var.has_discussions
  has_downloads   = var.has_downloads
  has_issues      = var.has_issues
  has_projects    = var.has_projects
  has_wiki        = var.visibility == "public"

  dynamic "pages" {
    for_each = local.pages != null ? [1] : []

    content {
      build_type = local.pages.build_type

      dynamic "source" {
        for_each = local.pages.build_type == "legacy" ? [1] : [0]

        content {
          branch = local.pages.source_branch
          path   = local.pages.source_path
        }
      }
    }
  }
}

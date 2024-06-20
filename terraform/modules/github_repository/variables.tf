################################################################################
# Repository Variables
################################################################################

variable "name" {
  type        = string
  description = "The name of the GitHub repository."
}

variable "description" {
  type        = string
  description = "A description of the repository."
  default     = ""
}

variable "homepage_url" {
  type        = string
  description = "The URL of a page describing the project."
  default     = ""
}

variable "topics" {
  type        = set(string)
  description = "The list of topics describing the repository."
  default     = []
}

variable "visibility" {
  type        = string
  description = <<-EOF
Can be 'public' or 'private'. If your organization is associated with an enterprise account using GitHub Enterprise Cloud or GitHub Enterprise Server 2.20+, visibility can also be 'internal'.
EOF
  validation {
    condition     = var.visibility == "public" || var.visibility == "private"
    error_message = "The value of visibility must be one of 'public' or 'private'."
  }
}

variable "has_discussions" {
  type        = bool
  description = "Set to 'true' to enable GitHub Discussions on the repository. Defaults to 'false'."
  default     = false
}

variable "has_downloads" {
  type        = bool
  description = "Set to 'true' to enable the (deprecated) downloads features on the repository."
  default     = true
}

variable "has_issues" {
  type        = bool
  description = "Set to 'true' to enable the GitHub Issues features on the repository."
  default     = true
}

variable "has_projects" {
  type        = bool
  description = <<-EOF
Set to 'true' to enable the GitHub Projects features on the repository. Per the GitHub documentation when in an organization that has disabled repository projects it will default to 'false' and will otherwise default to 'true'. If you specify 'true' when it has been disabled it will return an error.
EOF
  default     = true
}

variable "is_archived" {
  type        = bool
  description = "Whether or not the repository should be archived."
  default     = false
}

variable "collaborators" {
  type = list(object({
    username   = string,
    permission = string
  }))
  description = "The GitHub users who are authorized to collaborate on the repository."
  default     = []
}

variable "pages" {
  type = object({
    build_type    = string
    source_branch = optional(string)
    source_path   = optional(string)
  })
  description = "Attributes associated with the GitHub Pages environment for a repository"
  default     = null

  validation {
    condition     = var.pages != null ? contains(["legacy", "workflow"], var.pages.build_type) : true
    error_message = "The build type for GitHub pages must be one of: 'legacy', 'workflow'"
  }
}
locals {
  pages = var.pages == null ? null : {
    build_type    = var.pages.build_type
    source_branch = var.default_branch
    source_path   = var.pages.build_type == "legacy" ? "/docs" : "/"
  }
}

################################################################################
# Repository Branch Variables
################################################################################

variable "default_branch" {
  type        = string
  description = "The name of the default branch to create for the repository."
  default     = "main"
}

variable "allow_merge_commit" {
  type        = bool
  description = "Set to 'false' to disable merge commits to be created within the repository."
  default     = false
}

variable "allow_rebase_merge" {
  type        = bool
  description = "Set to 'false' to disable rebase merges to be created within the repository."
  default     = false
}

variable "allow_squash_merge" {
  type        = bool
  description = "Set to 'false' to disable squash merges to be created within the repository."
  default     = true
}

variable "delete_branch_on_merge" {
  type        = bool
  description = "Automatically delete head branch after a pull request is merged. Defaults to 'true'."
  default     = true
}

variable "branch_protection_rules" {
  description = "The branch protection rules to apply to the repository (the key of the map is the branch pattern to use)"
  type = map(object({
    allows_deletions                = optional(bool)
    allows_force_pushes             = optional(bool)
    blocks_creations                = optional(bool)
    enforce_admins                  = optional(bool)
    lock_branch                     = optional(bool)
    require_signed_commits          = optional(bool)
    require_conversation_resolution = optional(bool)
    push_restrictions               = optional(list(string))
    force_push_bypassers            = optional(list(string))
    required_linear_history         = optional(bool)
    required_pull_request_reviews = optional(object({
      dismiss_stale_reviews           = optional(bool)
      dismissal_restrictions          = optional(list(string))
      restrict_dismissals             = optional(bool)
      pull_request_bypassers          = optional(list(string))
      require_code_owner_reviews      = optional(bool)
      required_approving_review_count = optional(number)
      require_last_push_approval      = optional(bool)
    }))
    required_status_checks = optional(object({
      strict   = optional(bool)
      contexts = optional(list(string))
    }))
  }))
  default = {}
}
locals {
  default_branch_protection_rule = {
    "${var.default_branch}" = {
      enforce_admins          = true
      required_linear_history = true
      required_status_checks = {
        strict = true
      }
      required_pull_request_reviews = {
        required_approving_review_count = 0
      }
    }
  }
  branch_protection_rules = merge(
    local.default_branch_protection_rule,
    var.branch_protection_rules
  )
}

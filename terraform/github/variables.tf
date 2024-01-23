variable "changeset_bot_installation_id" {
  description = "The installation ID of the Changeset Bot GitHub App"
  type        = string
}

variable "default_branch" {
  description = "The default branch of a GitHub repository"
  type        = string
}

variable "repositories" {
  description = "The Effect-TS organization repositories whose configuration should be managed"
  type = map(object({
    description          = optional(string, "")
    topics               = optional(set(string), [])
    homepage_url         = optional(string, "")
    visibility           = optional(string, "public")
    is_archived          = optional(bool, false)
    has_discussions      = optional(bool, false)
    enable_changesets    = optional(bool, true)
    allow_squash_merge   = optional(bool, true)
    allow_rebase_merge   = optional(bool, false)
    has_release_branches = optional(bool, false)
    collaborators = optional(list(object({
      username   = string,
      permission = string
    })), [])
    pages = optional(object({
      build_type    = string
      source_branch = optional(string)
      source_path   = optional(string)
    }))
    branch_protection_rules = optional(map(object({
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
    })))
  }))
}

variable "organization_owners" {
  description = "The owners of the Effect-TS GitHub organization"
  type        = list(string)
}

variable "organization_members" {
  description = "The members of the Effect-TS GitHub organization"
  type        = list(string)
}

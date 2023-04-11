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
    description       = optional(string, ""),
    collaborators     = optional(list(object({ username = string, permission = string })), [])
    homepage_url      = optional(string)
    topics            = optional(list(string), []),
    visibility        = optional(string, "public")
    enable_pages      = optional(bool, true),
    enable_changesets = optional(bool, true)
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

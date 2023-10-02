locals {
  changeset_repositories = [
    for name, config in var.repositories :
    name if config.enable_changesets
  ]
}

resource "github_app_installation_repositories" "changeset-bot" {
  installation_id       = var.changeset_bot_installation_id
  selected_repositories = local.changeset_repositories
}

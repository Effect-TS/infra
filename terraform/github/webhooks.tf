locals {
  webhook_repositories = toset([
    for name, config in var.repositories :
    name if config.visibility == "public"
  ])
}

resource "github_repository_webhook" "discord" {
  for_each = local.webhook_repositories

  repository = each.key

  active = true
  events = [
    "issues",
    "pull_request",
    "release"
  ]

  configuration {
    url          = data.sops_file.secrets.data["discord_webhook_url"]
    content_type = "json"
    insecure_ssl = false
  }
}

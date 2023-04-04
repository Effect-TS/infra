resource "github_repository_webhook" "discord" {
  for_each = github_repository.repository

  repository = each.value.name

  active = true
  events = ["*"]

  configuration {
    url          = data.sops_file.secrets.data["discord_webhook_url"]
    content_type = "json"
    insecure_ssl = false
  }
}

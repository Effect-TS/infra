resource "github_repository_webhook" "discord" {
  for_each = github_repository.repository

  repository = each.value.name

  active = each.value.visibility == "public"
  events = ["*"]

  configuration {
    url          = data.sops_file.secrets.data["discord_webhook_url"]
    content_type = "json"
    insecure_ssl = false
  }
}

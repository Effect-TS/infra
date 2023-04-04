resource "github_repository_webhook" "discord" {
  for_each = {
    for repository in github_repository.repository :
    repository.name => repository.visibility if repository.visibility == "public"
  }

  repository = each.key

  active = true
  events = ["*"]

  configuration {
    url          = data.sops_file.secrets.data["discord_webhook_url"]
    content_type = "json"
    insecure_ssl = false
  }
}

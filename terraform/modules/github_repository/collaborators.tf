resource "github_repository_collaborators" "collaborators" {
  repository = github_repository.repository.name

  dynamic "user" {
    for_each = var.collaborators

    content {
      username   = user.value.username
      permission = user.value.permission
    }
  }
}

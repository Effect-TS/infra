# TODO
# resource "github_actions_organization_secret" "effect_bot_npm" {
#   secret_name     = "EFFECT_BOT_NPM"
#   visibility      = "private"
#   plaintext_value = TODO
# }

# resource "github_actions_organization_secret" "npm_token" {
#   secret_name     = "NPM_TOKEN"
#   visibility      = "private"
#   plaintext_value = TODO
# }

resource "github_actions_organization_permissions" "effect_ts" {
  allowed_actions      = "all"
  enabled_repositories = "all"
}

provider "sops" {}

data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

provider "github" {
  owner          = "Effect-TS"
  token          = data.sops_file.secrets.data["github_token"]
  read_delay_ms  = 100
  write_delay_ms = 100
}

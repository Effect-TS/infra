changeset_bot_installation_id = "35785996"

default_branch = "main"

repositories = {
  ".github" = {
    description       = "Organization-wide configuration for Effect-TS"
    enable_changesets = false
  }
  awesome-effect = {}
  babel-plugin = {
    description  = "A babel plugin purpose-built for the Effect ecosystem"
    homepage_url = "https://effect-ts.github.io/babel-plugin"
    pages        = { build_type = "legacy" }
  }
  build-utils = {
    description  = "Custom utilities used to assist with building and packaging Effect libraries"
    homepage_url = "https://effect-ts.github.io/build-utils"
    pages        = { build_type = "legacy" }
  }
  cache = {
    description  = "An Effect native cache with a simple and compositional interface"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  cli = {
    description  = "Rapidly build powerful and composable command-line applications"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  cluster = {
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  codemod = {
    description  = "Code mod's for the Effect ecosystem"
    homepage_url = "https://effect-ts.github.io/codemod"
  }
  data = {
    description   = "Custom built data types leveraged by the Effect ecosystem"
    collaborators = [{ username = "enricopolanski", permission = "push" }]
    homepage_url  = "https://effect.website"
    is_archived   = true
  }
  docgen = {
    description  = "An opinionated documentation generator for Effect projects"
    homepage_url = "https://effect-ts.github.io/docgen"
    pages        = { build_type = "legacy" }
  }
  docs-ai = {
    description       = "Experimentation with artificial intelligence for augmenting Effect's documentation"
    enable_changesets = false
    visibility        = "private"
  }
  discord-bot = {
    description       = "The Effect Community's custom Discord bot, built with Effect"
    enable_changesets = false
  }
  dtslint = {
    description = "Effect's custom fork of dtslint used to lint TypeScript declaration (.d.ts) files"
  }
  effect = {
    description        = "An ecosystem of tools to build robust applications in TypeScript"
    homepage_url       = "https://effect.website"
    topics             = ["javascript", "cli", "platform", "typescript", "schema", "effect", "opentelemetry"]
    pages              = { build_type = "workflow" }
    allow_rebase_merge = true
    collaborators      = []
    branch_protection_rules = {
      "next-*" = {
        allows_force_pushes = true
        required_status_checks = {
          strict = true
        }
      }
    }
  }
  eslint-plugin = {
    description = "A set of ESlint and TypeScript rules to work with Effect"
  }
  examples = {
    description = "A repository of examples showing how to use Effect"
  }
  experimental = {
    description  = "A repository for experimental Effect libraries"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  figlet = {
    description = "An implementation of a FIGlet font parser and renderer built with Effect"
  }
  # Comment in once the repo has commits
  # general-issues = {
  #   has_discussions = true
  #   has_pages       = false
  # }
  infra = {
    description       = "Infrastructure relevant to the Effect organization"
    enable_changesets = false
  }
  io = {
    description  = "Effect's core runtime, a fiber-based implementation of structured concurrency"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  language-service = {}
  match = {
    description   = "Functional pattern matching with the full power of TypeScript"
    topics        = ["functional-programming", "pattern-matching", "typescript"]
    homepage_url  = "https://effect.website"
    is_archived   = true
  }
  monaco-editor = {
    description = "A custom fork of Monaco Editor maintained for the Effect Playground"
  }
  monorepo-testing = {
    collaborators = [{ username = "fubhy", permission = "admin" }]
  }
  opentelemetry = {
    description  = "OpenTelemetry integration with Effect"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  platform = {
    description  = "Unified interfaces for common platform-specific services"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  printer = {
    description  = "An easy to use, extensible pretty-printer for rendering documents"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  rpc = {
    description  = ""
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  scala-playground = {
    description = "A Scala playground for the Effect maintainers"
  }
  schema = {
    description  = "Modeling the schema of data structures as first-class values"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  stm = {
    description  = "An implementation of software transactional memory built with Effect"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  stream = {
    description  = "An implementation of pull-based streams built with Effect"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  team = {
    visibility        = "private"
    enable_changesets = false
  }
  test = {
    homepage_url = "https://effect-ts.github.io/test"
    pages        = { build_type = "legacy" }
  }
  typeclass = {
    description  = "A collection of re-usable typeclasses for the Effect ecosystem"
    homepage_url = "https://effect.website"
    is_archived  = true
  }
  vite-plugin-react = {}
  vscode-extension = {
    description = "Tools to assist development with the Effect Typescript framework"
  }
  website = {
    description       = "Source code for Effect's documentation website"
    collaborators     = [{ username = "lukaswiesehan", permission = "push" }]
    homepage_url      = "https://www.effect.website"
    enable_changesets = false
  }
}

organization_owners = [
  "effect-bot",
  "gcanti",
  "IMax153",
  "mikearnaldi",
  "mirepri",
  "schickling",
  "fubhy",
  "tim-smart"
]

organization_members = [
  "mattiamanzati",
  "patroza",
  "DadeSko",
  "Andarist",
  "datner"
]

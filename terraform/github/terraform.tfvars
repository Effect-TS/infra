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
    homepage_url = "https://effect-ts.github.io/cache"
    pages        = { build_type = "legacy" }
    is_archived  = true
  }
  cli = {
    description  = "Rapidly build powerful and composable command-line applications"
    homepage_url = "https://effect-ts.github.io/cli"
    pages        = { build_type = "workflow" }
    is_archived  = true
  }
  cluster = {
    homepage_url = "https://effect-ts.github.io/cluster"
    pages        = { build_type = "workflow" }
    is_archived  = true
  }
  codemod = {
    description  = "Code mod's for the Effect ecosystem"
    homepage_url = "https://effect-ts.github.io/codemod"
    pages        = { build_type = "legacy" }
  }
  data = {
    description   = "Custom built data types leveraged by the Effect ecosystem"
    collaborators = [{ username = "enricopolanski", permission = "push" }]
    homepage_url  = "https://effect-ts.github.io/data"
    pages         = { build_type = "legacy" }
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
    collaborators     = [{ username = "tim-smart", permission = "push" }]
    enable_changesets = false
  }
  dtslint = {
    description = "Effect's custom fork of dtslint used to lint TypeScript declaration (.d.ts) files"
  }
  effect = {
    description        = "A fully-fledged functional effect system for TypeScript with a rich standard library"
    homepage_url       = "https://www.effect.website"
    topics             = ["effect-system", "fp", "framework", "stack-safe", "typescript", "zio"]
    pages              = { build_type = "workflow" }
    allow_rebase_merge = true
    collaborators = [
      { username = "DenisFrezzato", permission = "push" },
      { username = "isthatcentered", permission = "push" },
      { username = "remiguittaut", permission = "push" },
      { username = "rzeigler", permission = "push" },
    ]
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
    homepage_url = "https://effect-ts.github.io/experimental"
    pages        = { build_type = "legacy" }
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
    homepage_url = "https://effect-ts.github.io/io"
    pages        = { build_type = "legacy" }
    is_archived  = true
  }
  language-service = {}
  match = {
    description   = "Functional pattern matching with the full power of TypeScript"
    collaborators = [{ username = "tim-smart", permission = "maintain" }]
    pages         = { build_type = "legacy" }
    homepage_url  = "https://effect-ts.github.io/match"
    topics        = ["functional-programming", "pattern-matching", "typescript"]
    is_archived   = true
  }
  monorepo-testing = {
    collaborators = [{ username = "fubhy", permission = "admin" }]
  }
  opentelemetry = {
    description  = "OpenTelemetry integration with Effect"
    homepage_url = "https://effect-ts.github.io/opentelemetry"
    pages        = { build_type = "legacy" }
    is_archived  = true
  }
  platform = {
    description  = "Unified interfaces for common platform-specific services"
    homepage_url = "https://effect-ts.github.io/platform"
    pages        = { build_type = "legacy" }
    is_archived  = true
  }
  printer = {
    description  = "An easy to use, extensible pretty-printer for rendering documents"
    homepage_url = "https://effect-ts.github.io/printer"
    pages        = { build_type = "legacy" }
    is_archived  = true
  }
  rpc = {
    description  = ""
    homepage_url = "https://effect-ts.github.io/rpc"
    pages        = { build_type = "legacy" }
    is_archived  = true
  }
  scala-playground = {
    description = "A Scala playground for the Effect maintainers"
  }
  schema = {
    description  = "Modeling the schema of data structures as first-class values"
    homepage_url = "https://effect-ts.github.io/schema"
    pages        = { build_type = "legacy" }
    is_archived  = true
  }
  stm = {
    description  = "An implementation of software transactional memory built with Effect"
    homepage_url = "https://effect-ts.github.io/stm"
    pages        = { build_type = "legacy" }
    is_archived  = true
  }
  stream = {
    description  = "An implementation of pull-based streams built with Effect"
    homepage_url = "https://effect-ts.github.io/stream"
    pages        = { build_type = "legacy" }
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
    homepage_url = "https://effect-ts.github.io/typeclass"
    pages        = { build_type = "legacy" }
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
  "fubhy"
]

organization_members = [
  "0x706b",
  "aniravi24",
  "mattiamanzati",
  "patroza",
  "pigoz",
  "qlonik",
  "r-cyr",
  "sledorze",
  "steida",
  "tim-smart",
  "tstelzer",
  "wesselvdv",
  "ssalbdivad",
  "DadeSko",
  "Andarist"
]

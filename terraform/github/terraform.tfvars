changeset_bot_installation_id = "35785996"

default_branch = "main"

repositories = {
  babel-plugin = {
    description  = "A babel plugin purpose-built for the Effect ecosystem"
    homepage_url = "https://effect-ts.github.io/babel-plugin"
  }
  build-utils = {
    description  = "Customize utilities used to assist with building and packaging Effect libraries"
    homepage_url = "https://effect-ts.github.io/build-utils"
  }
  cache = {
    description  = "An Effect native cache with a simple and compositional interface"
    homepage_url = "https://effect-ts.github.io/cache"
  }
  cli = {
    description  = "Rapidly build powerful and composable command-line applications"
    homepage_url = "https://effect-ts.github.io/cli"
  }
  data = {
    description   = "Custom built data types leveraged by the Effect ecosystem"
    collaborators = [{ username = "enricopolanski", permission = "push" }]
    homepage_url  = "https://effect-ts.github.io/data"
  }
  docgen = {
    description  = "An opinionated documentation generator for Effect projects"
    homepage_url = "https://effect-ts.github.io/docgen"
  }
  discord-bot = {
    description       = "The Effect Community's custom Discord bot, built with Effect"
    collaborators     = [{ username = "tim-smart", permission = "push" }]
    enable_changesets = false
    enable_pages      = false
  }
  dtslint = {
    description  = "Effect's custom fork of dtslint used to lint TypeScript declaration (.d.ts) files"
    enable_pages = false
  }
  effect = {
    description = "A fully-fledged functional effect system for TypeScript with a rich standard library"
    collaborators = [
      { username = "DenisFrezzato", permission = "push" },
      { username = "isthatcentered", permission = "push" },
      { username = "remiguittaut", permission = "push" },
      { username = "rzeigler", permission = "push" },
    ]
    homepage_url = "https://effect-ts.github.io/effect"
    topics       = ["effect-system", "fp", "framework", "stack-safe", "typescript", "zio"]
  }
  eslint-plugin = {
    description  = "A set of ESlint and TypeScript rules to work with Effect"
    enable_pages = false
  }
  examples = {
    description  = "A repository of examples showing how to use Effect"
    enable_pages = false
  }
  # express = {
  #   description = "Express integration with Effect"
  # }
  fastify = {
    description = "Fastify integration with Effect"
    collaborators = [
      { username = "antoine-coulon", permission = "push" },
      { username = "jbmusso", permission = "push" },
      { username = "tarrsalah", permission = "push" }
    ]
    enable_pages = false
  }
  # figlet = {
  #   description = "An implementation of a FIGlet font parser and renderer built with Effect"
  # }
  html = {
    description  = ""
    enable_pages = false
  }
  infra = {
    description       = "Infrastructure relevant to the Effect organization"
    enable_changesets = false
    enable_pages      = false
  }
  io = {
    description  = "Effect's core runtime, a fiber-based implementation of structured concurrency"
    homepage_url = "https://effect-ts.github.io/io"
  }
  # jest = {
  #   description = ""
  # }
  language-service = {
    description  = ""
    enable_pages = false
  }
  match = {
    description   = "Functional pattern matching with the full power of TypeScript"
    collaborators = [{ username = "tim-smart", permission = "maintain" }]
    homepage_url  = "https://effect-ts.github.io/match"
    topics        = ["functional-programming", "pattern-matching", "typescript"]
  }
  misc = {
    description  = ""
    homepage_url = "https://effect-ts.github.io/misc"
    enable_pages = false
  }
  node = {
    description  = ""
    homepage_url = "https://effect-ts.github.io/node"
    topics       = ["functional", "node"]
    enable_pages = false
  }
  opentelemetry = {
    description  = "OpenTelemetry integration with Effect"
    homepage_url = "https://effect-ts.github.io/opentelemetry"
  }
  # otel = {
  #   description = ""
  # }
  platform = {
    description  = "Unified interfaces for common platform-specific services"
    enable_pages = false
  }
  printer = {
    description  = "An easy to use, extensible pretty-printer for rendering documents"
    homepage_url = "https://effect-ts.github.io/printer"
  }
  # process = {
  #   description = "A simple library for interacting with external processes and command-line programs via Effect"
  # }
  query = {
    description  = "Efficiently pipeline, batch, and cache requests to any data source"
    homepage_url = "https://effect-ts.github.io/query"
    topics       = ["batching", "caching", "functional", "pipelining", "query"]
  }
  remix-plugin = {
    description  = ""
    enable_pages = false
  }
  rpc = {
    description = ""
  }
  scala-playground = {
    description  = "A Scala playground for the Effect maintainers"
    enable_pages = false
  }
  schema = {
    description  = "Modeling the schema of data structures as first-class values"
    homepage_url = "https://effect-ts.github.io/schema"
  }
  sqlite = {
    description   = ""
    collaborators = [{ username = "lokhmakov", permission = "maintain" }]
    enable_pages  = false
  }
  stm = {
    description  = "An implementation of software transactional memory built with Effect"
    homepage_url = "https://effect-ts.github.io/stm"
  }
  stream = {
    description  = "An implementation of pull-based streams built with Effect"
    homepage_url = "https://effect-ts.github.io/stream"
  }
  test = {
    description  = ""
    homepage_url = "https://effect-ts.github.io/test"
  }
  vite-plugin = {
    description  = ""
    enable_pages = false
  }
  website = {
    description       = "Source code for Effect's documentation website"
    collaborators     = [{ username = "wpoosanguansit", permission = "push" }]
    homepage_url      = "https://www.effect.website"
    enable_changesets = false
    enable_pages      = false
  }
}

organization_owners = [
  "effect-bot",
  "gcanti",
  "IMax153",
  "mikearnaldi",
  "schickling"
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
  "wesselvdv"
]

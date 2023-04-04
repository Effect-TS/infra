locals {
  default_branch    = "main"
  homepage_base_url = "https://effect-ts.github.io"
  repositories = {
    babel-plugin = {
      description = "A babel plugin purpose-built for the Effect ecosystem"
    }
    cache = {
      description = "An Effect native cache with a simple and compositional interface"
    }
    cli = {
      description = "Rapidly build powerful and composable command-line applications"
    }
    data = {
      description = "Custom built data types leveraged by the Effect ecosystem"
    }
    effect = {
      description = "A fully-fledged functional effect system for TypeScript with a rich standard library"
      topics      = ["effect-system", "fp", "framework", "stack-safe", "typescript", "zio"]
    }
    eslint-plugin = {
      description   = "A set of ESlint and TypeScript rules to work with Effect"
      disable_pages = true
    }
    examples = {
      description   = "A repository of examples showing how to use Effect"
      disable_pages = true
    }
    # express = {
    #   description = "Express integration with Effect"
    # }
    fastify = {
      description   = "Fastify integration with Effect"
      disable_pages = true
    }
    # figlet = {
    #   description = "An implementation of a FIGlet font parser and renderer built with Effect"
    # }
    html = {
      description   = ""
      disable_pages = true
    }
    infra = {
      description   = "Infrastructure relevant to the Effect organization"
      disable_pages = true
      visibility    = "private"
    }
    io = {
      description = "Effect's core runtime, a fiber-based implementation of structured concurrency"
    }
    # jest = {
    #   description = ""
    # }
    language-service = {
      description   = ""
      disable_pages = true
    }
    match = {
      description   = "Functional pattern matching with the full power of TypeScript"
      topics        = ["functional-programming", "pattern-matching", "typescript"]
      disable_pages = true
    }
    misc = {
      description   = ""
      disable_pages = true
    }
    node = {
      description   = ""
      disable_pages = true
      topics        = ["functional", "node"]
    }
    opentelemetry = {
      description = "OpenTelemetry integration with Effect"
    }
    # otel = {
    #   description = ""
    # }
    platform = {
      description   = "Unified interfaces for common platform-specific services"
      disable_pages = true
    }
    printer = {
      description   = "An easy to use, extensible pretty-printer for rendering documents"
      disable_pages = true
    }
    # process = {
    #   description = "A simple library for interacting with external processes and command-line programs via Effect"
    # }
    query = {
      description = "Efficiently pipeline, batch, and cache requests to any data source"
      topics      = ["batching", "caching", "functional", "pipelining", "query"]
    }
    remix-plugin = {
      description   = ""
      disable_pages = true
    }
    rpc = {
      description   = ""
      disable_pages = true
    }
    scala-playground = {
      description   = "A Scala playground for the Effect maintainers"
      disable_pages = true
    }
    schema = {
      description = "Modeling the schema of data structures as first-class values"
    }
    sqlite = {
      description   = ""
      disable_pages = true
    }
    stm = {
      description = "An implementation of software transactional memory built with Effect"
    }
    stream = {
      description = "An implementation of pull-based streams built with Effect"
    }
    test = {
      description = ""
    }
    vite-plugin = {
      description   = ""
      disable_pages = true
    }
    website = {
      description   = "Source code for Effect's documentation website"
      disable_pages = true
    }
  }
}

resource "github_repository" "repository" {
  for_each = local.repositories

  name                        = each.key
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_squash_merge          = true
  delete_branch_on_merge      = true
  description                 = each.value.description
  has_downloads               = true
  has_issues                  = true
  has_projects                = true
  has_wiki                    = true
  homepage_url                = "${local.homepage_base_url}/${each.key}"
  squash_merge_commit_message = "BLANK"
  squash_merge_commit_title   = "PR_TITLE"
  topics                      = try(each.value.topics, [])
  visibility                  = try(each.value.visibility, "public")

  dynamic "pages" {
    for_each = can(each.value.disable_pages) ? [] : [1]

    content {
      source {
        branch = local.default_branch
        path   = "/docs"
      }
    }
  }
}

resource "github_branch" "main" {
  for_each = github_repository.repository

  branch     = local.default_branch
  repository = each.value.name
}

resource "github_branch_default" "main" {
  for_each = github_repository.repository

  branch     = local.default_branch
  repository = each.value.name
}

resource "github_branch_protection" "main" {
  for_each = {
    for repository in github_repository.repository :
    repository.name => repository.node_id if repository.visibility == "public"
  }

  repository_id           = each.value
  pattern                 = local.default_branch
  blocks_creations        = true
  enforce_admins          = true
  required_linear_history = true

  required_pull_request_reviews {
    required_approving_review_count = 0
  }
}

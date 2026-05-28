#' Interactive Vignette Architect
#' Scaffolds a CRAN-compliant RMarkdown vignette by interactively prompting
#' for metadata, narrative structure, and target functions.
#'
#' @export

architect_vignette <- function() {
  message("Initializing Vignette Architect...")
  
  # 1. Gather Metadata via Dynamic Prompts
  pkg_name <- readline(prompt = "Enter your package name: ")
  if (trimws(pkg_name) == "") return(message("Package name is required. Aborting."))
  
  vig_title <- readline(prompt = "Enter the Vignette Title (e.g., 'Getting Started'): ")
  if (trimws(vig_title) == "") vig_title <- "Package Vignette"
  
  # Create a clean filename from the title
  file_base <- tolower(gsub("[^[:alnum:]]", "_", vig_title))
  file_name <- sprintf("%s.Rmd", file_base)
  
  # 2. Determine the Narrative Structure
  vig_type <- select.list(
    choices = c("Quick Start Guide", "Deep Dive / Advanced Usage", "Case Study / Workflow"),
    title = "Select the structural template for this vignette:"
  )
  if (vig_type == "") return(message("Scaffolding cancelled."))
  
  # 3. Gather Target Functions
  funcs_input <- readline(prompt = "List the core functions to highlight (comma-separated, e.g., 'sweep_memory, audit_state'): ")
  funcs_list <- trimws(unlist(strsplit(funcs_input, ",")))
  funcs_list <- funcs_list[funcs_list != ""]
  
  # 4. Construct the CRAN-Compliant YAML Header
  yaml_block <- c(
    "---",
    sprintf("title: \"%s\"", vig_title),
    "output: rmarkdown::html_vignette",
    "vignette: >",
    sprintf("  %%\\VignetteIndexEntry{%s}", vig_title),
    "  %\\VignetteEngine{knitr::rmarkdown}",
    "  %\\VignetteEncoding{UTF-8}",
    "---",
    "",
    "```{r, include = FALSE}",
    "knitr::opts_chunk$set(",
    "  collapse = TRUE,",
    "  comment = \"#>\"",
    ")",
    "```",
    "",
    sprintf("```{r setup}"),
    sprintf("library(%s)", pkg_name),
    "```",
    ""
  )
  
  # 5. Construct the Narrative Scaffold
  body_block <- c(
    sprintf("# Introduction"),
    sprintf("This vignette demonstrates the core functionality of the `%s` package.", pkg_name),
    ""
  )
  
  if (vig_type == "Quick Start Guide") {
    body_block <- c(body_block, 
                    "## Installation",
                    "Briefly explain how to install and attach the package.",
                    "",
                    "## Basic Usage",
                    "Provide a minimal reproducible example."
    )
  } else if (vig_type == "Deep Dive / Advanced Usage") {
    body_block <- c(body_block, 
                    "## Core Concepts",
                    "Explain the underlying philosophy or architecture.",
                    "",
                    "## Advanced Configuration",
                    "Detail the optional parameters and edge cases."
    )
  } else {
    body_block <- c(body_block, 
                    "## The Problem",
                    "Describe the real-world scenario.",
                    "",
                    "## The Solution",
                    "Walk through the workflow step-by-step."
    )
  }
  
  body_block <- c(body_block, "")
  
  # 6. Inject Function-Specific Code Chunks
  if (length(funcs_list) > 0) {
    body_block <- c(body_block, "# Core Functions Walkthrough", "")
    for (func in funcs_list) {
      body_block <- c(
        body_block,
        sprintf("## Using `%s()`", func),
        sprintf("Describe what `%s()` does and when to use it.", func),
        "",
        sprintf("```{r example_%s}", func),
        sprintf("# Add example code for %s() here", func),
        "```",
        ""
      )
    }
  }
  
  # 7. File System Operations
  if (!dir.exists("vignettes")) {
    dir.create("vignettes")
    message("Created 'vignettes/' directory.")
  }
  
  file_path <- file.path("vignettes", file_name)
  
  if (file.exists(file_path)) {
    overwrite <- select.list(c("Yes", "No"), title = sprintf("'%s' already exists. Overwrite?", file_name))
    if (overwrite != "Yes") return(message("Scaffolding aborted to protect existing file."))
  }
  
  # 8. Write the final file
  writeLines(c(yaml_block, body_block), con = file_path)
  message(sprintf("\nSuccess! Scaffolding complete. Open 'vignettes/%s' to start writing.", file_name))
  
  return(invisible(TRUE))
}
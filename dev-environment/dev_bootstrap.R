#' Initialize Development Environment
#' Scans for core R package development tools, prompts for installation of missing 
#' packages, and selectively loads them into the current session.

bootstrap_dev_env <- function() {
  # The essential toolkit for CRAN-ready package development
  core_tools <- c("devtools", "roxygen2", "usethis", "testthat", "knitr")
  
  # Identify what is currently installed
  installed <- rownames(installed.packages())
  missing_tools <- setdiff(core_tools, installed)
  
  message("Checking development environment...")
  
  # Step 1: Handle missing packages interactively
  if (length(missing_tools) > 0) {
    message("The following development tools are missing from your system:")
    print(missing_tools)
    
    to_install <- select.list(
      choices = c("Install All Missing", missing_tools, "Skip Installation"),
      multiple = TRUE,
      title = "Select packages to install right now:"
    )
    
    if (!"Skip Installation" %in% to_install && length(to_install) > 0) {
      if ("Install All Missing" %in% to_install) {
        install.packages(missing_tools)
      } else {
        install.packages(to_install)
      }
      message("Installation complete.")
    } else {
      message("Skipping installation.")
    }
  } else {
    message("All core development tools are already installed on your system.")
  }
  
  # Step 2: Dynamically load tools for the current session
  # Re-evaluate installed packages in case new ones were just added
  available_tools <- intersect(core_tools, rownames(installed.packages()))
  
  to_load <- select.list(
    choices = available_tools,
    multiple = TRUE,
    title = "Select development tools to attach to this session:"
  )
  
  if (length(to_load) > 0) {
    for (pkg in to_load) {
      suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    }
    message(sprintf("Successfully attached: %s", paste(to_load, collapse = ", ")))
  } else {
    message("No development tools attached.")
  }
  
  return(invisible(TRUE))
}
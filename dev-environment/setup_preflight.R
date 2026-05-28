#' Interactive Pre-Flight Dispatcher
#' Generates a custom Git pre-commit hook by asking the user step-by-step 
#' which safety checks to enforce before allowing a commit.
#'
#' @export

setup_preflight <- function() {
  message("Initializing Pre-Flight Dispatcher...")
  
  # 1. Verify Environment
  if (!dir.exists(".git")) {
    return(message("Error: Not a Git repository. Please run this at the root of your project."))
  }
  if (!dir.exists(".git/hooks")) {
    dir.create(".git/hooks", showWarnings = FALSE)
  }
  
  hook_path <- ".git/hooks/pre-commit"
  
  # 2. Step-by-Step Configuration
  message("\n--- Configuring Safety Checks ---")
  
  # Prompt 1: Documentation
  run_docs <- select.list(
    choices = c("Yes", "No"),
    title = "1. Automatically run devtools::document() to update help files before every commit?"
  )
  
  # Prompt 2: Testing
  run_tests <- select.list(
    choices = c("Yes", "No"),
    title = "2. Require all testthat tests to pass before allowing a commit?"
  )
  
  # Prompt 3: Styling
  run_style <- select.list(
    choices = c("Yes", "No"),
    title = "3. Automatically standardize code format using styler::style_pkg()?"
  )
  
  if (run_docs == "No" && run_tests == "No" && run_style == "No") {
    return(message("All checks skipped. No pre-commit hook generated."))
  }
  
  # 3. Construct the Bash Hook Script
  hook_lines <- c(
    "#!/bin/sh",
    "# Auto-generated pre-commit hook by Pre-Flight Dispatcher",
    "",
    "echo '\\n--- Running R Pre-Flight Checks ---'"
  )
  
  if (run_style == "Yes") {
    hook_lines <- c(
      hook_lines,
      "echo '-> Styling code...'",
      "Rscript -e \"if (requireNamespace('styler', quietly = TRUE)) styler::style_pkg()\"",
      "# Automatically stage any files modified by styler",
      "git add \\*.R"
    )
  }
  
  if (run_docs == "Yes") {
    hook_lines <- c(
      hook_lines,
      "echo '-> Updating documentation...'",
      "Rscript -e \"if (requireNamespace('devtools', quietly = TRUE)) devtools::document()\"",
      "# Automatically stage the NAMESPACE and man/ directory in case they were updated",
      "git add NAMESPACE man/\\*"
    )
  }
  
  if (run_tests == "Yes") {
    hook_lines <- c(
      hook_lines,
      "echo '-> Running tests...'",
      "# Using StopReporter so the script exits with an error code if ANY test fails",
      "Rscript -e \"if (requireNamespace('testthat', quietly = TRUE)) testthat::test_local(reporter = testthat::StopReporter)\"",
      "if [ $? -ne 0 ]; then",
      "  echo '\\n[!] Tests failed. Commit aborted. Fix the errors and try again.'",
      "  exit 1",
      "fi"
    )
  }
  
  hook_lines <- c(
    hook_lines,
    "echo '--- All Checks Passed. Committing... ---'",
    "exit 0",
    ""
  )
  
  # 4. File Writing & Protection
  if (file.exists(hook_path)) {
    overwrite <- select.list(
      choices = c("Yes", "No"),
      title = "A pre-commit hook already exists. Overwrite it?"
    )
    if (overwrite == "No") return(message("Aborted. Existing hook was protected."))
  }
  
  writeLines(hook_lines, con = hook_path)
  
  # 5. Make the hook executable
  # This is strictly required for Git to be allowed to run the script
  Sys.chmod(hook_path, mode = "0755")
  
  message("\nSuccess! Your Pre-Flight Dispatcher is armed and active.")
  message("These checks will now run invisibly in the background every time you type `git commit`.")
  
  return(invisible(TRUE))
}
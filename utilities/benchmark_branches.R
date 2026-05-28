#' Branch-Based Performance Benchmarker
#' Interactively selects Git branches, runs a target script in an isolated environment,
#' and compares the execution times across the selected branches.
#' 
#' @return Invisible data frame of benchmark results.
#' @export

benchmark_branches <- function() {
  # 1. Verify Git environment
  if (system("git rev-parse --is-inside-work-tree", ignore.stderr = TRUE, intern = FALSE) != 0) {
    return(message("Error: Not currently inside a Git repository. Please navigate to a valid repo."))
  }
  
  # 2. Extract available branches
  branches <- system("git branch --format='%(refname:short)'", intern = TRUE)
  
  if (length(branches) < 2) {
    return(message("Error: Found fewer than 2 branches. You need at least two to compare performance."))
  }
  
  # 3. Dynamic Selection: Specific vs. All Branches
  selection_type <- select.list(
    choices = c("Select specific branches", "Benchmark ALL branches"),
    title = "How would you like to select branches for testing?"
  )
  
  if (selection_type == "") return(message("Benchmarking cancelled."))
  
  if (selection_type == "Select specific branches") {
    target_branches <- select.list(
      choices = branches,
      multiple = TRUE,
      title = "Select at least two branches to compare (Ctrl/Cmd + Click):"
    )
    if (length(target_branches) < 2) {
      return(message("Error: You must select at least two branches for a comparison."))
    }
  } else {
    target_branches <- branches
  }
  
  # 4. Dynamic Selection: Target Script
  script_file <- readline(prompt = "Enter the exact path of the R script to benchmark (e.g., 'tests/speed_test.R'): ")
  if (!file.exists(script_file)) {
    return(message(sprintf("Error: Cannot find the file '%s'.", script_file)))
  }
  
  # 5. Preserve Current State
  current_branch <- system("git branch --show-current", intern = TRUE)
  has_changes <- length(system("git status --porcelain", intern = TRUE)) > 0
  
  if (has_changes) {
    message("Detected uncommitted changes. Stashing them for safety during the benchmark...")
    system("git stash -q")
  }
  
  # 6. The Benchmarking Loop
  results <- list()
  message(sprintf("\n--- Starting Benchmark for %d Branches ---", length(target_branches)))
  
  for (branch in target_branches) {
    message(sprintf("\n-> Checking out branch: %s", branch))
    system(sprintf("git checkout %s -q", branch))
    
    message(sprintf("   Running '%s'...", script_file))
    
    start_time <- Sys.time()
    status <- "Success"
    
    # Run the script in an isolated environment so branches don't pollute each other's data
    tryCatch({
      sandbox_env <- new.env()
      source(script_file, local = sandbox_env)
    }, error = function(e) {
      status <- "Failed"
      message(sprintf("   [!] Execution error on branch '%s': %s", branch, e$message))
    })
    
    end_time <- Sys.time()
    elapsed <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    results[[branch]] <- data.frame(
      Branch = branch,
      Time_Seconds = round(elapsed, 4),
      Status = status,
      stringsAsFactors = FALSE
    )
  }
  
  # 7. Cleanup and State Restoration
  message(sprintf("\nRestoring original branch: %s", current_branch))
  system(sprintf("git checkout %s -q", current_branch))
  
  if (has_changes) {
    message("Popping stash to restore your uncommitted changes...")
    system("git stash pop -q")
  }
  
  # 8. Compile and Sort Results
  final_results <- do.call(rbind, results)
  # Sort so the fastest branch is at the top
  final_results <- final_results[order(final_results$Time_Seconds), ]
  rownames(final_results) <- NULL
  
  message("\n--- Performance Benchmark Results ---")
  print(final_results)
  
  return(invisible(final_results))
}
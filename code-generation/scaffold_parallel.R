#' Interactive CPU Architect
#' Scans local hardware to determine available CPU cores and generates 
#' a robust parallel processing scaffold for high-volume data tasks.
#'
#' @export

scaffold_parallel <- function() {
  message("Initializing CPU Architect...")
  
  # 1. Hardware Scan
  if (!requireNamespace("parallel", quietly = TRUE)) {
    return(message("Error: The built-in 'parallel' package is missing."))
  }
  
  total_cores <- parallel::detectCores()
  
  if (is.na(total_cores)) {
    return(message("Error: Could not determine hardware specifications."))
  }
  
  message(sprintf("Hardware Scan Complete: %d CPU cores detected.", total_cores))
  
  # 2. Interactive Core Selection
  # It is best practice to leave at least 1 core free so the OS doesn't freeze
  safe_max <- max(1, total_cores - 1)
  core_options <- as.character(seq(1, total_cores))
  
  core_prompt <- sprintf(
    "How many cores do you want to dedicate to this task? (Max recommended: %d)", 
    safe_max
  )
  
  chosen_cores <- select.list(
    choices = core_options,
    title = core_prompt
  )
  
  if (chosen_cores == "") return(message("Scaffolding cancelled."))
  
  # 3. Gather Target Data and Function
  data_obj <- readline(prompt = "Enter the name of the list or vector you are iterating over (e.g., 'massive_dataset'): ")
  if (trimws(data_obj) == "") data_obj <- "my_data"
  
  func_name <- readline(prompt = "Enter the name of the function to apply to each element (e.g., 'process_file'): ")
  if (trimws(func_name) == "") func_name <- "my_heavy_function"
  
  # 4. Generate the Scaffold
  scaffold_lines <- c(
    "# --- Auto-Generated Parallel Cluster ---",
    "library(parallel)",
    "",
    sprintf("num_cores <- %s", chosen_cores),
    "message(sprintf('Initializing local cluster with %d cores...', num_cores))",
    "",
    "# 1. Create the background worker cluster",
    "cl <- makeCluster(num_cores)",
    "",
    "# 2. Export necessary functions and variables to the workers",
    "# Note: If your function relies on external packages, use clusterEvalQ(cl, library(pkg_name))",
    sprintf("clusterExport(cl, varlist = c('%s'))", func_name),
    "",
    "# 3. Execute the heavy processing",
    "message('Running parallel computation. Please wait...')",
    "start_time <- Sys.time()",
    "",
    sprintf("results <- parLapply(cl, X = %s, fun = %s)", data_obj, func_name),
    "",
    "end_time <- Sys.time()",
    "",
    "# 4. Safely shut down the cluster to free up the CPU",
    "stopCluster(cl)",
    "",
    "elapsed <- as.numeric(difftime(end_time, start_time, units = 'secs'))",
    "message(sprintf('Computation finished successfully in %.2f seconds.', elapsed))",
    "# ---------------------------------------"
  )
  
  # 5. Output 
  message("\n--- Generated Parallel Snippet ---")
  cat(scaffold_lines, sep = "\n")
  
  out_choice <- select.list(
    choices = c("Done", "Save to parallel_scaffold.R"), 
    title = "\nAction: Copy the block above, or save it directly to a file?"
  )
  
  if (out_choice == "Save to parallel_scaffold.R") {
    writeLines(scaffold_lines, con = "parallel_scaffold.R")
    message("Success: Snippet saved to 'parallel_scaffold.R' in your working directory.")
  }
  
  return(invisible(TRUE))
}
#' Clean-Room Simulator
#' Runs a script in a background vanilla R session. If it fails due to missing 
#' dependencies or variables, it interactively injects the fix into the file.
#'
#' @export

simulate_clean_room <- function() {
  message("Initializing Clean-Room Environment...")
  
  # 1. Select the target script
  scripts <- list.files(pattern = "\\.R$", ignore.case = TRUE)
  if (length(scripts) == 0) return(message("Error: No R scripts found in the current directory."))
  
  target_script <- select.list(scripts, title = "Select a script to stress-test:")
  if (target_script == "") return(message("Simulation cancelled."))
  
  testing <- TRUE
  attempt <- 1
  
  # 2. The Testing Loop
  while (testing) {
    message(sprintf("\n--- Attempt %d: Running '%s' in a vanilla session ---", attempt, target_script))
    
    # Run in a completely isolated background process
    # system2 captures both standard output and standard error
    res <- suppressWarnings(system2(
      "Rscript", 
      args = c("--vanilla", target_script), 
      stdout = TRUE, 
      stderr = TRUE
    ))
    
    # Check the exit status attribute (NULL means success)
    status <- attr(res, "status")
    
    if (is.null(status) || status == 0) {
      message("\nSUCCESS! The script ran perfectly in an isolated environment.")
      message("It is 100% reproducible.")
      testing <- FALSE
      
    } else {
      # 3. Parse the Error
      message("\n[!] SIMULATION FAILED. The script broke in a clean environment.")
      
      # Extract the actual error message from the stderr output
      error_lines <- res[grepl("Error", res, ignore.case = TRUE)]
      if (length(error_lines) > 0) {
        error_msg <- paste(error_lines, collapse = "\n")
        message("\n--- Crash Report ---")
        message(error_msg)
        message("--------------------\n")
      } else {
        error_msg <- paste(tail(res, 3), collapse = "\n") # Fallback to last few lines
        message("Crash output:\n", error_msg)
      }
      
      # 4. Interactive Diagnosis & Snippet Generation
      fix_type <- select.list(
        choices = c(
          "Inject missing library() call", 
          "Inject custom code snippet (e.g., missing variable)", 
          "Abort Simulation"
        ),
        title = "How would you like to fix this?"
      )
      
      if (fix_type == "Abort Simulation" || fix_type == "") {
        message("Simulation aborted. File left in its current state.")
        return(invisible(FALSE))
      }
      
      snippet_to_inject <- ""
      
      if (fix_type == "Inject missing library() call") {
        # Helper to extract a guessed function name to prompt the user
        pkg_guess <- readline(prompt = "Enter the name of the missing package: ")
        if (trimws(pkg_guess) != "") {
          snippet_to_inject <- sprintf("library(%s)", trimws(pkg_guess))
        }
      } else {
        message("Enter the exact R code to inject at the top of the file.")
        snippet_to_inject <- readline(prompt = "Snippet: ")
      }
      
      # 5. File Injection
      if (snippet_to_inject != "") {
        # Read the current file
        current_code <- readLines(target_script, warn = FALSE)
        
        # Prepend the new snippet
        updated_code <- c(
          sprintf("%s # [Auto-injected by Clean-Room Simulator]", snippet_to_inject),
          current_code
        )
        
        # Write it back to the file
        writeLines(updated_code, con = target_script)
        message(sprintf("\nSuccess: Injected '%s' at line 1.", snippet_to_inject))
        
        # Ask to re-run
        re_run <- select.list(c("Yes", "No"), title = "Run the simulation again with the fix?")
        if (re_run != "Yes") {
          testing <- FALSE
          message("Simulation paused. You can resume testing later.")
        } else {
          attempt <- attempt + 1
        }
        
      } else {
        message("No valid snippet provided. Simulation aborted.")
        testing <- FALSE
      }
    }
  }
  
  return(invisible(TRUE))
}
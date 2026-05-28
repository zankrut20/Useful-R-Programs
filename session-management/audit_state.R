#' Silent State Auditor
#' Takes a snapshot of global options, graphical parameters, and working directory,
#' sources a script, and interactively helps you revert hijacked settings.
#'
#' @export

audit_script <- function() {
  message("Initializing Silent State Auditor...")
  
  # 1. Ask for the target script
  scripts <- list.files(pattern = "\\.R$", ignore.case = TRUE)
  if (length(scripts) == 0) return(message("Error: No R scripts found in the current directory."))
  
  target_script <- select.list(scripts, title = "Select a script to audit:")
  if (target_script == "") return(message("Audit cancelled."))
  
  message(sprintf("\n--- Taking Pre-Execution Snapshot ---", target_script))
  
  # 2. Capture the "Before" State
  pre_wd <- getwd()
  pre_opts <- options()
  # par() can fail if no graphics device is active, so we wrap it safely
  pre_par <- tryCatch(par(no.readonly = TRUE), error = function(e) list())
  
  # 3. Execute the Script
  message(sprintf("Running '%s'...", target_script))
  tryCatch({
    source(target_script)
  }, error = function(e) {
    message(sprintf("\n[!] Script crashed with error: %s", e$message))
    message("Auditing state changes made right before the crash...")
  })
  
  # 4. Capture the "After" State
  post_wd <- getwd()
  post_opts <- options()
  post_par <- tryCatch(par(no.readonly = TRUE), error = function(e) list())
  
  # 5. The Interrogation Loop
  changes_found <- FALSE
  message("\n--- Analyzing State Hijacks ---")
  
  # Helper function to generate clean interactive prompts for changes
  revert_prompt <- function(category, item, old_val, new_val) {
    # Keep output clean if values are massive vectors
    old_str <- if(length(old_val) > 1) paste(old_val[1:2], collapse=", ") else deparse(old_val)[1]
    new_str <- if(length(new_val) > 1) paste(new_val[1:2], collapse=", ") else deparse(new_val)[1]
    
    prompt_title <- sprintf("[%s] '%s' changed. \n  Old: %s \n  New: %s \nAction:", 
                            category, item, old_str, new_str)
    
    choice <- select.list(c("Keep New Setting", "Revert to Old Snapshot"), title = prompt_title)
    return(choice == "Revert to Old Snapshot")
  }
  
  # Check 1: Working Directory Hijacks
  if (!identical(pre_wd, post_wd)) {
    changes_found <- TRUE
    if (revert_prompt("Directory", "getwd()", pre_wd, post_wd)) {
      setwd(pre_wd)
      message("-> Reverted: Working directory restored.")
    }
  }
  
  # Check 2: Global Options Hijacks (e.g., scipen, stringsAsFactors)
  opt_names <- unique(c(names(pre_opts), names(post_opts)))
  for (opt in opt_names) {
    old_o <- pre_opts[[opt]]
    new_o <- post_opts[[opt]]
    
    if (!identical(old_o, new_o)) {
      changes_found <- TRUE
      if (revert_prompt("Option", opt, old_o, new_o)) {
        # Dynamically reset the option
        do.call(options, setNames(list(old_o), opt))
        message(sprintf("-> Reverted: option('%s') restored.", opt))
      }
    }
  }
  
  # Check 3: Graphical Parameters Hijacks (e.g., margins, layout)
  if (length(pre_par) > 0 && length(post_par) > 0) {
    par_names <- names(pre_par)
    for (p in par_names) {
      old_p <- pre_par[[p]]
      new_p <- post_par[[p]]
      
      if (!identical(old_p, new_p)) {
        changes_found <- TRUE
        if (revert_prompt("Graphics", p, old_p, new_p)) {
          # Dynamically reset the parameter
          do.call(par, setNames(list(old_p), p))
          message(sprintf("-> Reverted: par('%s') restored.", p))
        }
      }
    }
  }
  
  # 6. Conclusion
  if (!changes_found) {
    message("\nAudit Complete: No global state changes detected. Your environment is safe.")
  } else {
    message("\nAudit Complete: Selected state restorations have been applied to your session.")
  }
  
  return(invisible(TRUE))
}
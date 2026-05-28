#' Function Masking Detective
#' Scans for namespace conflicts and interactively resolves them.
#' Automatically adapts its output based on whether you are developing 
#' a package or writing a standalone analysis script.
#' 
#' @return Invisible TRUE if successful.
#' @export

detect_masking <- function() {
  # 1. Identify conflicts across all attached packages
  all_confs <- conflicts(detail = TRUE)
  
  # Filter for conflicts that only involve multiple attached packages
  pkg_confs <- list()
  for (func in names(all_confs)) {
    envs <- all_confs[[func]]
    # Extract only package environments, ignoring the global env
    pkg_envs <- envs[grepl("^package:", envs)]
    if (length(pkg_envs) > 1) {
      pkg_confs[[func]] <- gsub("^package:", "", pkg_envs)
    }
  }
  
  if (length(pkg_confs) == 0) {
    return(message("No cross-package function masking detected. Your namespace is clean."))
  }
  
  message(sprintf("Detected %d masked functions.", length(pkg_confs)))
  
  # 2. Interactive Step-by-Step Resolution
  resolutions <- list()
  for (func in names(pkg_confs)) {
    pkgs <- pkg_confs[[func]]
    
    prompt_title <- sprintf("Conflict for '%s()'. Which package should take priority?", func)
    chosen_pkg <- select.list(
      choices = c(pkgs, "Skip/Ignore"),
      title = prompt_title
    )
    
    if (chosen_pkg != "" && chosen_pkg != "Skip/Ignore") {
      resolutions[[func]] <- chosen_pkg
    }
  }
  
  if (length(resolutions) == 0) {
    return(message("No conflict resolutions selected."))
  }
  
  # 3. Determine Context: Package Development vs. Standalone Script
  is_pkg_dev <- file.exists("DESCRIPTION")
  
  message("\n--- Recommended Resolution Actions ---")
  
  if (is_pkg_dev) {
    message("Context: Package Development (Detected DESCRIPTION file in root)")
    
    # Requirement 1: Update DESCRIPTION
    unique_pkgs <- unique(unlist(resolutions))
    message("\n1. Ensure the following are listed under 'Imports:' in your DESCRIPTION file:")
    message(paste("   Imports:", paste(unique_pkgs, collapse = ", ")))
    
    # Requirement 2: roxygen2 tags
    message("\n2. Add these roxygen2 tags to your package documentation to safely lock the namespace:")
    for (func in names(resolutions)) {
      message(sprintf("   #' @importFrom %s %s", resolutions[[func]], func))
    }
    message("\n   (Alternatively, strict `pkg::func()` syntax can be used within your source code).")
    
  } else {
    message("Context: Standalone Analysis Script")
    message("\nAdd the following snippet at the top of your script (immediately AFTER your library() calls) to lock in your namespace priorities:\n")
    
    # Generate copy-pasteable script block
    cat("# --- Namespace Conflict Resolutions ---\n")
    for (func in names(resolutions)) {
      cat(sprintf("%s <- %s::%s\n", func, resolutions[[func]], func))
    }
    cat("# --------------------------------------\n")
    
    # Optional: Apply instantly to the current session to save time
    apply_now <- select.list(
      choices = c("Yes", "No"), 
      title = "\nApply these resolutions to your current active session right now?"
    )
    
    if (apply_now == "Yes") {
      for (func in names(resolutions)) {
        # Assign the preferred function directly to the Global Environment
        assign(func, getExportedValue(resolutions[[func]], func), envir = .GlobalEnv)
      }
      message("Success: Priorities applied to the Global Environment.")
    }
  }
  
  return(invisible(TRUE))
}
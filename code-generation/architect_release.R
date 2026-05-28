#' Interactive Release Candidate Architect
#' Automates version bumping in DESCRIPTION and interactively scaffolds 
#' formatted release notes in NEWS.md by prompting the user step-by-step.
#'
#' @export

architect_release <- function() {
  message("Initializing Release Candidate Architect...")
  
  # 1. Verify Package Environment
  if (!file.exists("DESCRIPTION")) {
    return(message("Error: DESCRIPTION file not found. Are you in the package root?"))
  }
  
  # 2. Parse Current Version
  desc_info <- read.dcf("DESCRIPTION")
  pkg_name <- as.character(desc_info[, "Package"])
  current_version <- as.character(desc_info[, "Version"])
  
  message(sprintf("\nDetected Package: %s", pkg_name))
  message(sprintf("Current Version:  %s", current_version))
  
  # Split version into components (assuming standard x.y.z format)
  v_parts <- as.numeric(unlist(strsplit(current_version, "\\.")))
  if (length(v_parts) < 3) v_parts <- c(v_parts, rep(0, 3 - length(v_parts)))
  
  # 3. Ask the user what kind of release this is
  bump_type <- select.list(
    choices = c("Patch (Bug fixes: x.y.Z+1)", 
                "Minor (New features: x.Y+1.0)", 
                "Major (Breaking changes: X+1.0.0)", 
                "Cancel"),
    title = "\nWhat type of version bump is this?"
  )
  
  if (bump_type == "Cancel" || bump_type == "") return(message("Release preparation cancelled."))
  
  # 4. Calculate New Version
  if (grepl("Patch", bump_type)) {
    new_version <- sprintf("%d.%d.%d", v_parts[1], v_parts[2], v_parts[3] + 1)
  } else if (grepl("Minor", bump_type)) {
    new_version <- sprintf("%d.%d.0", v_parts[1], v_parts[2] + 1)
  } else {
    new_version <- sprintf("%d.0.0", v_parts[1] + 1)
  }
  
  # 5. Confirm and Update DESCRIPTION
  confirm_desc <- select.list(
    choices = c("Yes", "No"),
    title = sprintf("\nUpdate DESCRIPTION from %s to %s?", current_version, new_version)
  )
  
  if (confirm_desc == "Yes") {
    desc_info[, "Version"] <- new_version
    desc_info[, "Date"] <- as.character(Sys.Date())
    write.dcf(desc_info, file = "DESCRIPTION")
    message(sprintf("-> Success: DESCRIPTION updated to v%s", new_version))
  }
  
  # 6. Interactively Build NEWS.md
  update_news <- select.list(
    choices = c("Yes", "No"),
    title = "\nWould you like to draft the release notes for NEWS.md now?"
  )
  
  if (update_news == "Yes") {
    message("\n--- Drafting Release Notes ---")
    message("Enter your changelog items one by one. Leave blank and press Enter to finish.")
    
    news_bullets <- character()
    adding_items <- TRUE
    counter <- 1
    
    # Ask for inputs one by one to build the changelog
    while (adding_items) {
      bullet <- readline(prompt = sprintf("Bullet %d: ", counter))
      
      if (trimws(bullet) == "") {
        adding_items <- FALSE
      } else {
        news_bullets <- c(news_bullets, sprintf("* %s", trimws(bullet)))
        counter <- counter + 1
      }
    }
    
    if (length(news_bullets) > 0) {
      news_header <- sprintf("# %s %s", pkg_name, new_version)
      news_block <- c(news_header, "", news_bullets, "", "")
      
      # Check if NEWS.md exists, if so, prepend. Otherwise, create.
      if (file.exists("NEWS.md")) {
        current_news <- readLines("NEWS.md", warn = FALSE)
        writeLines(c(news_block, current_news), con = "NEWS.md")
      } else {
        writeLines(news_block, con = "NEWS.md")
      }
      
      message("-> Success: NEWS.md updated with your latest changes.")
    } else {
      message("No items entered. Skipping NEWS.md update.")
    }
  }
  
  message(sprintf("\nRelease Candidate v%s is prepped and ready!", new_version))
  return(invisible(TRUE))
}
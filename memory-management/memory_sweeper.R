#' Interactive Memory Sweeper
#' Scans the global environment for heavy objects and prompts for removal.

sweep_memory <- function() {
  # Dynamically ask for the threshold during execution
  thresh_input <- readline(prompt = "Enter minimum object size to flag (in MB, e.g., 50): ")
  threshold <- suppressWarnings(as.numeric(thresh_input))
  
  if (is.na(threshold)) {
    message("Invalid input. Defaulting to 50 MB.")
    threshold <- 50
  }

  env_objs <- ls(envir = .GlobalEnv)
  if (length(env_objs) == 0) {
    return(message("The global environment is empty."))
  }

  # Calculate object sizes in MB
  obj_sizes <- sapply(env_objs, function(x) object.size(get(x, envir = .GlobalEnv)) / (1024^2))
  large_objs <- obj_sizes[obj_sizes >= threshold]

  if (length(large_objs) == 0) {
    return(message(sprintf("No objects found larger than %s MB.", threshold)))
  }

  # Format choices for the selection menu
  large_objs <- sort(large_objs, decreasing = TRUE)
  display_names <- sprintf("%s (%.2f MB)", names(large_objs), large_objs)

  # Trigger interactive prompt
  to_remove <- select.list(
    choices = display_names,
    multiple = TRUE,
    title = "Select large objects to wipe from memory (0 to cancel):"
  )

  if (length(to_remove) > 0) {
    actual_names <- sapply(strsplit(to_remove, " \\("), `[`, 1)
    rm(list = actual_names, envir = .GlobalEnv)
    gc() # Force garbage collection to instantly free up RAM
    message(sprintf("Successfully removed %d objects and cleared memory.", length(actual_names)))
  } else {
    message("Memory sweep cancelled.")
  }
}
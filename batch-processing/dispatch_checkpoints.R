#' Checkpoint Dispatcher
#' A crash-resilient wrapper for batch processing. Silently caches progress 
#' at defined intervals and interactively recovers from interrupted sessions.
#'
#' @param items A vector or list of items to process.
#' @param target_func The function to apply to each item.
#' @param checkpoint_file Character. The file path for the state cache.
#' @return A list of successfully processed results.
#' @export

dispatch_checkpoints <- function(items, target_func, checkpoint_file = "batch_checkpoint.rds") {
  total_items <- length(items)
  start_index <- 1
  results <- vector("list", total_items)
  
  message(sprintf("Initializing Checkpoint Dispatcher for %d items...", total_items))
  
  # 1. Check for existing crash data
  if (file.exists(checkpoint_file)) {
    cached_state <- readRDS(checkpoint_file)
    crashed_at <- cached_state$current_index
    
    prompt_msg <- sprintf(
      "Found an existing checkpoint. The previous run stopped at item %d of %d.",
      crashed_at, total_items
    )
    
    action <- select.list(
      choices = c(
        sprintf("Resume exactly where I left off (Start at %d)", crashed_at),
        "Wipe the cache and restart from the beginning",
        "Abort completely"
      ),
      title = prompt_msg
    )
    
    if (action == "Abort completely" || action == "") {
      return(message("Dispatcher aborted."))
    } else if (grepl("Resume", action)) {
      start_index <- crashed_at
      results <- cached_state$results
      message(sprintf("Resuming batch process at iteration %d...", start_index))
    } else {
      message("Cache wiped. Starting fresh...")
    }
  }
  
  # 2. Set the Save Interval
  freq_input <- readline(prompt = "How often should progress be saved? (Enter a number, e.g., 100): ")
  save_freq <- suppressWarnings(as.numeric(freq_input))
  
  if (is.na(save_freq) || save_freq <= 0) {
    message("Invalid input. Defaulting to saving every 50 iterations.")
    save_freq <- 50
  }
  
  # 3. The Execution Loop
  for (i in start_index:total_items) {
    
    # Execute with error trapping
    tryCatch({
      results[[i]] <- target_func(items[[i]])
    }, error = function(e) {
      # On crash, force a final save of the exact failure point
      crash_state <- list(current_index = i, results = results)
      saveRDS(crash_state, file = checkpoint_file)
      
      message(sprintf("\n[!] CRITICAL ERROR at iteration %d:", i))
      message(sprintf("    %s", e$message))
      message(sprintf("-> State safely cached to '%s'. You can fix the bug and resume later.", checkpoint_file))
      
      # Stop the execution entirely
      stop("Batch processing halted due to error.", call. = FALSE)
    })
    
    # 4. Interval Checkpointing
    if (i %% save_freq == 0) {
      current_state <- list(current_index = i + 1, results = results)
      saveRDS(current_state, file = checkpoint_file)
      message(sprintf("  ... Checkpoint saved at iteration %d", i))
    }
  }
  
  # 5. Clean Up on Success
  if (file.exists(checkpoint_file)) {
    unlink(checkpoint_file)
  }
  
  message(sprintf("\nSuccess! All %d items processed. Temporary checkpoint files cleared.", total_items))
  return(invisible(results))
}
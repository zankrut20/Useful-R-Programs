#' Bulk Loop Guardian
#' A memory-safe wrapper for heavy iterations. Monitors RAM usage and 
#' triggers an interactive failsafe if the environment approaches critical capacity.
#'
#' @param items A vector or list of items to process.
#' @param target_func The function to apply to each item.
#' @param limit_mb Numeric. The memory limit in megabytes before triggering the alarm.
#' @param save_path Character. Where to dump the emergency checkpoint data.
#' @return A list of successfully processed results.
#' @export

loop_guardian <- function(items, target_func, limit_mb = 4000, save_path = "emergency_checkpoint.rds") {
  message(sprintf("Starting Guardian Loop for %d items. Memory limit: %d MB.", length(items), limit_mb))
  
  results <- list()
  total_items <- length(items)
  
  for (i in seq_len(total_items)) {
    # 1. Execute the target function on the current item
    tryCatch({
      results[[i]] <- target_func(items[[i]])
    }, error = function(e) {
      message(sprintf("\n[!] Execution error at iteration %d: %s", i, e$message))
      results[[i]] <- NA 
    })
    
    # 2. Memory Check (Run every 50 iterations to avoid slowing down the loop)
    if (i %% 50 == 0) {
      # gc() column 2 contains the memory used in MB for Ncells and Vcells
      mem_stats <- gc(reset = FALSE)
      current_mem_mb <- sum(mem_stats[, 2]) 
      
      if (current_mem_mb >= limit_mb) {
        message(sprintf("\n[WARNING] Critical Memory Threshold Reached: %.2f MB", current_mem_mb))
        
        # Force an immediate deep clean to see if we can recover RAM
        invisible(gc(reset = TRUE, full = TRUE))
        recovered_mem <- sum(gc(reset = FALSE)[, 2])
        
        message(sprintf("Post-GC Memory: %.2f MB", recovered_mem))
        
        # If GC didn't solve it, trigger the interactive alarm
        if (recovered_mem >= limit_mb) {
          alarm_prompt <- sprintf(
            "Iteration %d of %d. RAM is critically high. Action required:", 
            i, total_items
          )
          
          action <- select.list(
            choices = c(
              "Save current progress to disk and Abort",
              "Ignore limit and attempt to Continue",
              "Abort immediately (Lose unsaved progress)"
            ),
            title = alarm_prompt
          )
          
          if (action == "Save current progress to disk and Abort") {
            saveRDS(results, file = save_path)
            message(sprintf("Emergency checkpoint saved to '%s'. Loop aborted safely.", save_path))
            return(invisible(results))
            
          } else if (action == "Abort immediately (Lose unsaved progress)" || action == "") {
            message("Loop aborted by user. Progress lost.")
            return(invisible(results))
            
          } else {
            message("Overriding memory limits. Continuing the loop...")
          }
        }
      }
    }
  }
  
  message("\nSuccess: All items processed without breaching memory limits.")
  return(invisible(results))
}
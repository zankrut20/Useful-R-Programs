#' The Network Diplomat
#' Safely executes network requests across a list of URLs or endpoints.
#' Interactively calculates safe rate limits and automatically retries failed 
#' requests using exponential backoff.
#'
#' @param targets A vector of URLs or target IDs to process.
#' @param target_func The function that makes the network request (takes one target).
#' @param max_retries Integer. Maximum number of times to retry a single failure.
#' @return A list of successfully processed results, with NAs for permanent failures.
#' @export

network_diplomat <- function(targets, target_func, max_retries = 3) {
  total_targets <- length(targets)
  message(sprintf("Initializing Network Diplomat for %d targets...", total_targets))
  
  # 1. Interactively Determine the Rate Limit
  rate_prompt <- "Enter the server's rate limit (Requests per MINUTE). \n(If unsure, 30 is a safe default for most public APIs): "
  rate_input <- readline(prompt = rate_prompt)
  
  req_per_min <- suppressWarnings(as.numeric(rate_input))
  if (is.na(req_per_min) || req_per_min <= 0) {
    message("Invalid input. Defaulting to a highly polite 30 requests per minute.")
    req_per_min <- 30
  }
  
  # Calculate exact sleep time per request
  base_sleep <- 60 / req_per_min
  message(sprintf("-> Rate limit locked. The Diplomat will pause for %.2f seconds between requests.", base_sleep))
  
  results <- vector("list", total_targets)
  
  # 2. The Throttled Execution Loop
  for (i in seq_len(total_targets)) {
    target <- targets[i]
    success <- FALSE
    attempt <- 1
    
    # 3. The Retry & Backoff Manager
    while (!success && attempt <= max_retries) {
      
      tryCatch({
        # Attempt the network request
        results[[i]] <- target_func(target)
        success <- TRUE
        
        # Only sleep if it's not the very last item
        if (i < total_targets) {
          Sys.sleep(base_sleep)
        }
        
      }, error = function(e) {
        # Catch timeouts, 404s, 429s, or disconnected networks
        err_msg <- trimws(e$message)
        message(sprintf("\n[!] Connection Error at index %d (Attempt %d of %d):", i, attempt, max_retries))
        message(sprintf("    Target: %s", target))
        message(sprintf("    Error:  %s", err_msg))
        
        if (attempt < max_retries) {
          # Exponential Backoff: Wait longer after each consecutive failure
          # e.g., 5 seconds, then 10 seconds, then 20 seconds
          backoff_time <- 5 * (2 ^ (attempt - 1))
          
          # If it's explicitly a 429 Too Many Requests, add a heavy penalty delay
          if (grepl("429|Too Many Requests", err_msg, ignore.case = TRUE)) {
            message("    -> Server explicitly requested a slow down (HTTP 429).")
            backoff_time <- backoff_time + 15
          }
          
          message(sprintf("-> Diplomat backing off for %.1f seconds before retrying...", backoff_time))
          Sys.sleep(backoff_time)
          
        } else {
          message("-> Max retries exhausted. Diplomat abandoning this target.")
          results[[i]] <- NA # Log as failed and move on so the script doesn't die
        }
      })
      
      attempt <- attempt + 1
    }
    
    # Optional: Print a subtle progress tracker every 10% 
    if (i %% max(1, floor(total_targets / 10)) == 0) {
      message(sprintf("... Progress: %d / %d completed", i, total_targets))
    }
  }
  
  message(sprintf("\nDiplomacy Complete! All %d targets processed.", total_targets))
  return(invisible(results))
}
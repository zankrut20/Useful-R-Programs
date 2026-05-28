#' Session Sentinel
#' Interactively configures dual-logging for the current R session.
#' Invisibility routes messages, warnings, and errors to a text file 
#' while maintaining live console output.
#'
#' @export

setup_sentinel <- function() {
  message("Initializing Session Sentinel...")
  
  # 1. Verify R Version capability
  if (getRversion() < "4.0.0") {
    return(message("Error: Session Sentinel requires R 4.0.0 or higher for global calling handlers."))
  }
  
  # 2. Ask for Logging Level
  log_level <- select.list(
    choices = c("All Output (Messages, Warnings, Errors)", "Errors Only", "Cancel"),
    title = "Would you like to log this session?"
  )
  
  if (log_level == "Cancel" || log_level == "") {
    return(message("Sentinel setup cancelled."))
  }
  
  # 3. Ask for Log Filename dynamically
  default_name <- sprintf("session_log_%s.txt", format(Sys.time(), "%Y%m%d_%H%M"))
  prompt_text <- sprintf("Enter log filename (or press Enter for '%s'): ", default_name)
  
  log_file <- readline(prompt = prompt_text)
  if (trimws(log_file) == "") log_file <- default_name
  
  # Ensure the file exists and write the header
  file.create(log_file, showWarnings = FALSE)
  cat(sprintf("--- Session Log Started: %s ---\n", Sys.time()), file = log_file, append = TRUE)
  
  # 4. Define the routing logic
  # This helper formats the output with a timestamp and the message type
  write_to_log <- function(type, msg) {
    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    # Clean up the message string to prevent double line-breaks
    clean_msg <- trimws(msg)
    log_entry <- sprintf("[%s] [%s] %s\n", timestamp, type, clean_msg)
    
    cat(log_entry, file = log_file, append = TRUE)
  }
  
  # 5. Attach the Global Calling Handlers
  # These sit in the background and catch conditions as they happen,
  # routing them to our file without stopping them from printing to the console.
  
  if (log_level == "All Output (Messages, Warnings, Errors)") {
    globalCallingHandlers(
      message = function(m) { write_to_log("MESSAGE", m$message) },
      warning = function(w) { write_to_log("WARNING", w$message) },
      error   = function(e) { write_to_log("ERROR", e$message) }
    )
    message(sprintf("\nSentinel Active: Dual-logging ALL output to '%s'", log_file))
    
  } else {
    globalCallingHandlers(
      error = function(e) { write_to_log("ERROR", e$message) }
    )
    message(sprintf("\nSentinel Active: Dual-logging ERRORS ONLY to '%s'", log_file))
  }
  
  message("You can now safely run your batch processes.")
  return(invisible(TRUE))
}
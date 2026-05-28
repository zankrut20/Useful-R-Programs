#' Zombie Data Hunter
#' Hunts down invisible memory hogs like massive temporary files, 
#' unclosed graphical devices, and uncollected garbage, prompting 
#' the user for targeted cleaning.
#'
#' @export

hunt_zombies <- function() {
  message("Scanning system for Zombie Data...")
  
  # 1. Analyze Temporary Directory (The biggest hidden storage hog)
  tmp_dir <- tempdir()
  tmp_files <- list.files(tmp_dir, full.names = TRUE, recursive = TRUE)
  tmp_size_mb <- sum(file.info(tmp_files)$size, na.rm = TRUE) / (1024^2)
  
  # 2. Analyze Graphical Devices (Hidden plot histories)
  open_devs <- dev.list()
  dev_count <- length(open_devs)
  
  # 3. Build Interactive Menu Options Dynamically
  choices <- c()
  
  if (tmp_size_mb > 5) {
    choices <- c(choices, sprintf("Flush Temporary Directory (%.2f MB wasted)", tmp_size_mb))
  }
  
  if (dev_count > 0) {
    choices <- c(choices, sprintf("Close Active Graphical Devices (%d open)", dev_count))
  }
  
  choices <- c(choices, "Force Deep Garbage Collection (Clear orphaned closures)", "Cancel")
  
  # 4. Trigger Interactive Step-by-Step Resolution
  message("\n--- Hidden Memory Hogs Detected ---")
  actions <- select.list(
    choices = choices, 
    multiple = TRUE,
    title = "Select which zombie data to eradicate (Ctrl/Cmd + Click):"
  )
  
  if (length(actions) == 0 || "Cancel" %in% actions) {
    return(message("Zombie hunt cancelled."))
  }
  
  # 5. Execute Selected Actions
  if (any(grepl("Flush Temporary Directory", actions))) {
    # Unlink deletes the files. Recreate the empty tempdir just in case the active session needs it.
    unlink(tmp_dir, recursive = TRUE, force = TRUE)
    dir.create(tmp_dir, showWarnings = FALSE)
    message(sprintf("Success: Flushed %.2f MB from hidden temporary storage.", tmp_size_mb))
  }
  
  if (any(grepl("Close Active Graphical", actions))) {
    graphics.off()
    message(sprintf("Success: Closed %d orphaned graphical devices and cleared plot history.", dev_count))
  }
  
  if (any(grepl("Force Deep Garbage", actions))) {
    # Running gc() twice forces R to clear both older and newer generations of memory
    invisible(gc(reset = TRUE, full = TRUE))
    invisible(gc(reset = TRUE, full = TRUE))
    message("Success: Forced deep garbage collection. Orphaned RAM freed.")
  }
  
  message("\nSystem is clean.")
  return(invisible(TRUE))
}
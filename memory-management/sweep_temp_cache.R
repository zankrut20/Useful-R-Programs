#' Temp-Cache Janitor
#' Scans hidden R temporary directories for abandoned session data and caches,
#' categorizes the storage waste, and interactively prompts for safe deletion.
#'
#' @export

sweep_temp_cache <- function() {
  message("Scanning system for hidden R temporary caches...")
  
  # 1. Identify the base temporary directory for the OS
  # tempdir() gives the current session's folder. dirname() goes one level up 
  # to the OS folder where ALL R sessions (past and present) dump their data.
  base_tmp <- dirname(tempdir())
  
  # 2. Find all R session temp directories (usually named RtmpXXXXXX)
  all_rtmp_dirs <- list.dirs(base_tmp, recursive = FALSE, full.names = TRUE)
  r_tmp_dirs <- all_rtmp_dirs[grepl("Rtmp", basename(all_rtmp_dirs))]
  
  if (length(r_tmp_dirs) == 0) {
    return(message("No R temporary directories found. Your system is clean."))
  }
  
  # 3. Initialize categorization lists
  categories <- list(
    "Knitr/RMarkdown Caches" = character(),
    "Downloaded Packages/Tarballs" = character(),
    "Raster/Image Processing Files" = character(),
    "General Session Temp Data" = character()
  )
  
  # 4. Scan and categorize files
  for (dir in r_tmp_dirs) {
    files <- list.files(dir, recursive = TRUE, full.names = TRUE)
    
    # Categorize based on extensions or naming patterns
    categories[["Knitr/RMarkdown Caches"]] <- c(
      categories[["Knitr/RMarkdown Caches"]],
      files[grepl("(_cache|\\.utf8\\.md|\\.knit\\.md)$", files)]
    )
    
    categories[["Downloaded Packages/Tarballs"]] <- c(
      categories[["Downloaded Packages/Tarballs"]],
      files[grepl("(\\.tar\\.gz|\\.zip|\\.tgz)$", files)]
    )
    
    categories[["Raster/Image Processing Files"]] <- c(
      categories[["Raster/Image Processing Files"]],
      files[grepl("(\\.grd|\\.gri|\\.tif|\\.png|\\.jpg)$", files)]
    )
    
    # Everything else goes to general
    categorized_files <- c(categories[[1]], categories[[2]], categories[[3]])
    categories[["General Session Temp Data"]] <- c(
      categories[["General Session Temp Data"]],
      setdiff(files, categorized_files)
    )
  }
  
  # 5. Calculate sizes and build menu options dynamically
  menu_choices <- character()
  action_map <- list()
  
  for (cat_name in names(categories)) {
    files <- categories[[cat_name]]
    if (length(files) > 0) {
      size_mb <- sum(file.info(files)$size, na.rm = TRUE) / (1024^2)
      
      # Only flag buckets that are actually taking up measurable space
      if (size_mb > 0.1) { 
        display_name <- sprintf("%s (%.2f MB across %d files)", cat_name, size_mb, length(files))
        menu_choices <- c(menu_choices, display_name)
        action_map[[display_name]] <- files
      }
    }
  }
  
  if (length(menu_choices) == 0) {
    return(message("Temporary directories exist, but they are practically empty. No sweeping needed."))
  }
  
  menu_choices <- c(menu_choices, "Cancel")
  
  # 6. Interactive Step-by-Step Resolution
  message("\n--- Hidden Cache Analysis ---")
  to_flush <- select.list(
    choices = menu_choices,
    multiple = TRUE,
    title = "Select which cache buckets to permanently flush (Ctrl/Cmd + Click):"
  )
  
  if (length(to_flush) == 0 || "Cancel" %in% to_flush) {
    return(message("Janitor sweep cancelled. No files were deleted."))
  }
  
  # 7. Execute Deletion
  total_freed <- 0
  for (choice in to_flush) {
    files_to_delete <- action_map[[choice]]
    
    # Force deletion of the selected files
    unlink(files_to_delete, force = TRUE)
    
    # Calculate actual freed space based on original file sizes
    total_freed <- total_freed + sum(file.info(files_to_delete)$size, na.rm = TRUE) / (1024^2)
    message(sprintf("-> Flushed: %s", choice))
  }
  
  # 8. Deep Clean: Prune abandoned empty directories
  # If a previous session crashed and we just emptied its folder, delete the folder itself.
  active_tmp <- tempdir()
  for (dir in r_tmp_dirs) {
    # Never delete the active session's root temp folder, even if empty
    if (dir != active_tmp && length(list.files(dir, all.files = TRUE, no.. = TRUE)) == 0) {
      unlink(dir, recursive = TRUE, force = TRUE)
    }
  }
  
  message(sprintf("\nSweep complete. Reclaimed %.2f MB of hidden storage.", total_freed))
  return(invisible(TRUE))
}
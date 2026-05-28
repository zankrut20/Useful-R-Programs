#' Interactive Dependency Diplomat (Base R Edition)
#' Scans package source code for external package calls and cross-references 
#' them against the DESCRIPTION file to interactively resolve missing, unused, 
#' or misclassified dependencies without requiring any external tools.
#'
#' @export

audit_dependencies <- function() {
  message("Initializing Dependency Diplomat (Zero-Dependency Edition)...")
  
  # 1. Verify Package Infrastructure
  if (!file.exists("DESCRIPTION")) {
    return(message("Error: DESCRIPTION file not found. Please run from the package root."))
  }
  
  # 2. Base R DCF Parsers and Modifiers
  desc <- read.dcf("DESCRIPTION")
  desc_modified <- FALSE
  
  # Helper to get clean package names (ignoring versions)
  get_clean_deps <- function(field) {
    if (field %in% colnames(desc)) {
      deps <- unlist(strsplit(desc[, field], ","))
      deps <- trimws(gsub("\\(.*?\\)", "", deps))
      return(deps[deps != "" & deps != "R"])
    }
    return(character())
  }
  
  # Helper to safely add a package to a field
  add_dep <- function(pkg, field) {
    if (field %in% colnames(desc)) {
      current_val <- desc[, field]
      desc[, field] <<- paste0(trimws(current_val), ",\n    ", pkg)
    } else {
      new_col <- matrix(pkg, ncol = 1)
      colnames(new_col) <- field
      desc <<- cbind(desc, new_col)
    }
    desc_modified <<- TRUE
  }
  
  # Helper to safely remove a package (preserving versions of other packages)
  remove_dep <- function(pkg, field) {
    if (field %in% colnames(desc)) {
      parts <- unlist(strsplit(desc[, field], ","))
      # Regex matches the exact package name, optionally followed by (>= version)
      pattern <- sprintf("^\\s*%s(\\s*\\(.*\\))?\\s*$", pkg)
      keep_parts <- parts[!grepl(pattern, parts)]
      
      if (length(keep_parts) > 0) {
        desc[, field] <<- paste(trimws(keep_parts), collapse = ",\n    ")
      } else {
        # If it was the only package, remove the field entirely
        desc <<- desc[, colnames(desc) != field, drop = FALSE]
      }
      desc_modified <<- TRUE
    }
  }
  
  current_imports <- get_clean_deps("Imports")
  current_suggests <- get_clean_deps("Suggests")
  all_declared <- c(current_imports, current_suggests)
  
  # 3. Scan Source Code for Actual Usage
  regex_colon <- "([a-zA-Z0-9\\.]+)::[a-zA-Z0-9\\._]+"
  regex_library <- "library\\(\\s*([a-zA-Z0-9\\.]+)\\s*\\)|require\\(\\s*([a-zA-Z0-9\\.]+)\\s*\\)"
  
  scan_directory <- function(dir_name) {
    if (!dir.exists(dir_name)) return(character())
    files <- list.files(dir_name, pattern = "\\.[R|Rmd|rmd]$", full.names = TRUE, recursive = TRUE)
    
    found_pkgs <- character()
    for (f in files) {
      lines <- readLines(f, warn = FALSE)
      
      colons <- regmatches(lines, gregexpr(regex_colon, lines))
      colons <- unlist(colons)
      if (length(colons) > 0) found_pkgs <- c(found_pkgs, gsub("::.*", "", colons))
      
      libs <- regmatches(lines, gregexpr(regex_library, lines))
      libs <- unlist(libs)
      if (length(libs) > 0) {
        clean_libs <- gsub("library\\(|require\\(|\\)|\\s", "", libs)
        found_pkgs <- c(found_pkgs, clean_libs)
      }
    }
    return(unique(found_pkgs))
  }
  
  message("Scanning source code for dependencies...")
  used_in_R <- scan_directory("R")
  used_in_tests <- scan_directory("tests")
  used_in_vigs <- scan_directory("vignettes")
  
  all_used <- unique(c(used_in_R, used_in_tests, used_in_vigs))
  base_pkgs <- c("base", "stats", "utils", "methods", "graphics", "grDevices", "datasets", "tools")
  all_used <- setdiff(all_used, base_pkgs)
  used_in_R <- setdiff(used_in_R, base_pkgs)
  
  # 4. Identify Discrepancies
  ghost_deps <- setdiff(all_used, all_declared)
  bloat_deps <- setdiff(all_declared, all_used)
  misclassified <- intersect(setdiff(current_imports, used_in_R), c(used_in_tests, used_in_vigs))
  
  if (length(ghost_deps) == 0 && length(bloat_deps) == 0 && length(misclassified) == 0) {
    return(message("\nPerfect! Your DESCRIPTION file perfectly matches your source code."))
  }
  
  message("\n--- Dependency Discrepancies Found ---")
  
  # 5. Resolve Ghost Dependencies (Used but not declared)
  if (length(ghost_deps) > 0) {
    message(sprintf("\n[!] GHOST DEPENDENCIES: %d packages used in code but missing from DESCRIPTION.", length(ghost_deps)))
    for (pkg in ghost_deps) {
      target_field <- ifelse(pkg %in% used_in_R, "Imports", "Suggests")
      if (select.list(c("Yes", "No"), title = sprintf("Add '%s' to %s?", pkg, target_field)) == "Yes") {
        add_dep(pkg, target_field)
      }
    }
  }
  
  # 6. Resolve Misclassified (Should be Suggests, not Imports)
  if (length(misclassified) > 0) {
    message(sprintf("\n[!] MISCLASSIFIED: %d packages in 'Imports' are only used in tests/vignettes.", length(misclassified)))
    for (pkg in misclassified) {
      if (select.list(c("Yes", "No"), title = sprintf("Move '%s' from Imports to Suggests?", pkg)) == "Yes") {
        remove_dep(pkg, "Imports")
        add_dep(pkg, "Suggests")
      }
    }
  }
  
  # 7. Resolve Bloat (Declared but never used)
  if (length(bloat_deps) > 0) {
    message(sprintf("\n[!] BLOAT DEPENDENCIES: %d packages in DESCRIPTION are never called in your code.", length(bloat_deps)))
    for (pkg in bloat_deps) {
      # Determine where it currently lives to construct the prompt
      loc <- ifelse(pkg %in% current_imports, "Imports", "Suggests")
      if (select.list(c("Yes", "No"), title = sprintf("Remove unused '%s' from %s?", pkg, loc)) == "Yes") {
        remove_dep(pkg, loc)
      }
    }
  }
  
  # 8. Save Changes
  if (desc_modified) {
    write.dcf(desc, "DESCRIPTION")
    message("\n-> Success! DESCRIPTION file successfully updated using Base R.")
  } else {
    message("\n-> Audit complete. No changes were written to the DESCRIPTION file.")
  }
  
  return(invisible(TRUE))
}
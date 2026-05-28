#' Interactive Identity Masker
#' Safely anonymizes PII in a dataset by interactively prompting the user 
#' to keep, drop, or scramble each column.
#'
#' @export

mask_identity <- function() {
  message("Initializing Identity Masker...")
  
  # 1. Select the Dataframe
  env_objs <- ls(envir = .GlobalEnv)
  df_names <- env_objs[sapply(env_objs, function(x) is.data.frame(get(x, envir = .GlobalEnv)))]
  
  if (length(df_names) == 0) return(message("No dataframes found in the global environment."))
  
  target_df_name <- select.list(df_names, title = "Select the dataset to anonymize:")
  if (target_df_name == "") return(message("Masking cancelled."))
  
  df <- get(target_df_name, envir = .GlobalEnv)
  col_names <- names(df)
  n_rows <- nrow(df)
  
  message(sprintf("\n--- Masking Dataset: '%s' (%d rows, %d columns) ---", target_df_name, n_rows, length(col_names)))
  
  masked_df <- df
  cols_to_drop <- character()
  
  # 2. Iterate and Prompt
  for (col in col_names) {
    col_type <- class(df[[col]])[1]
    
    prompt_msg <- sprintf("Column: '%s' (Type: %s). Action:", col, col_type)
    action <- select.list(
      choices = c("Keep", "Scramble", "Drop"),
      title = prompt_msg
    )
    
    if (action == "Drop" || action == "") {
      cols_to_drop <- c(cols_to_drop, col)
      message(sprintf("  -> Dropped '%s'", col))
      
    } else if (action == "Scramble") {
      if (col_type %in% c("numeric", "integer")) {
        # Shuffle the numeric values to break the link to the individual row,
        # while preserving the overall statistical distribution.
        masked_df[[col]] <- sample(df[[col]])
        message(sprintf("  -> Scrambled (Shuffled) numeric data in '%s'", col))
      } else {
        # Replace characters/factors with generic sequential placeholders
        masked_df[[col]] <- sprintf("Masked_%04d", seq_len(n_rows))
        message(sprintf("  -> Scrambled (Replaced) text data in '%s'", col))
      }
    } else {
      message(sprintf("  -> Kept '%s' as is", col))
    }
  }
  
  # Remove dropped columns
  if (length(cols_to_drop) > 0) {
    masked_df <- masked_df[, !(names(masked_df) %in% cols_to_drop), drop = FALSE]
  }
  
  # 3. Output Resolution
  out_name <- paste0(target_df_name, "_masked")
  assign(out_name, masked_df, envir = .GlobalEnv)
  
  message(sprintf("\nSuccess! Anonymized dataset saved to environment as '%s'.", out_name))
  
  # 4. Reprex Generation (Reproducible Example)
  gen_reprex <- select.list(
    choices = c("Yes", "No"),
    title = "Would you like to print the dput() output to the console for easy sharing?"
  )
  
  if (gen_reprex == "Yes") {
    # Limit to first 20 rows so a massive dataset doesn't crash the console output
    cat("\n--- Copy the code below to share your data safely ---\n")
    dput(head(masked_df, 20))
    cat("------------------------------------------------------\n")
    if (n_rows > 20) message("Note: dput() output was limited to the first 20 rows for brevity.")
  }
  
  return(invisible(masked_df))
}
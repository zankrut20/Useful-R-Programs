#' Interactive Test-Suite Architect
#' Scaffolds CRAN-compliant 'testthat' boilerplate for a specific function 
#' by asking the user about expected behaviors, outputs, and edge cases.
#'
#' @export

scaffold_tests <- function() {
  message("Initializing Test-Suite Architect...")
  
  # 1. Verify Package Infrastructure
  if (!dir.exists("tests/testthat")) {
    message("Error: 'tests/testthat' directory not found.")
    message("Hint: Run `usethis::use_testthat()` first to set up your testing infrastructure.")
    return(invisible(FALSE))
  }
  
  # 2. Target Function Input
  target_func <- readline(prompt = "Enter the exact name of the function you want to test: ")
  if (trimws(target_func) == "") return(message("Scaffolding cancelled."))
  
  file_name <- sprintf("test-%s.R", target_func)
  file_path <- file.path("tests", "testthat", file_name)
  
  if (file.exists(file_path)) {
    overwrite <- select.list(c("Yes", "No"), title = sprintf("'%s' already exists. Overwrite?", file_name))
    if (overwrite != "Yes") return(message("Aborted to protect existing tests."))
  }
  
  # 3. Interactive Test Design
  message(sprintf("\n--- Designing tests for %s() ---", target_func))
  
  out_type <- select.list(
    choices = c("data.frame / tibble", "list", "character", "numeric", "None/Unknown"),
    title = "1. What is the expected output type of this function?"
  )
  
  test_errors <- select.list(
    choices = c("Yes", "No"),
    title = "2. Should we generate an edge-case test for missing or invalid inputs (expect_error)?"
  )
  
  test_dims <- "No"
  if (out_type == "data.frame / tibble") {
    test_dims <- select.list(
      choices = c("Yes", "No"),
      title = "3. Should we include tests for output dimensions (row/column counts)?"
    )
  }
  
  # 4. Construct the Boilerplate
  test_lines <- c(
    sprintf("# Auto-generated tests for %s()", target_func),
    "library(testthat)",
    "",
    sprintf("test_that(\"%s() returns the correct data type\", {", target_func),
    sprintf("  # TODO: Define a minimal input object for testing"),
    sprintf("  # input_data <- ... "),
    sprintf("  # result <- %s(input_data)", target_func),
    ""
  )
  
  # Inject Output Type Tests
  if (out_type == "data.frame / tibble") {
    test_lines <- c(test_lines, "  expect_s3_class(result, \"data.frame\")")
  } else if (out_type == "list") {
    test_lines <- c(test_lines, "  expect_type(result, \"list\")")
  } else if (out_type == "character") {
    test_lines <- c(test_lines, "  expect_type(result, \"character\")")
  } else if (out_type == "numeric") {
    test_lines <- c(test_lines, "  expect_type(result, \"double\")")
  }
  
  # Inject Dimension Tests
  if (test_dims == "Yes") {
    test_lines <- c(
      test_lines,
      "  # expect_equal(nrow(result), expected_rows)",
      "  # expect_equal(ncol(result), expected_cols)"
    )
  }
  
  test_lines <- c(test_lines, "})", "")
  
  # Inject Error Handling Tests
  if (test_errors == "Yes") {
    test_lines <- c(
      test_lines,
      sprintf("test_that(\"%s() handles invalid inputs safely\", {", target_func),
      sprintf("  expect_error(%s(NULL)) # TODO: Update with your specific failure trigger", target_func),
      sprintf("  expect_error(%s(NA))", target_func),
      "})",
      ""
    )
  }
  
  # 5. File Output
  writeLines(test_lines, con = file_path)
  
  message(sprintf("\nSuccess! Scaffolding complete."))
  message(sprintf("-> Open '%s' to fill in your mock data and run your tests.", file_path))
  
  return(invisible(TRUE))
}
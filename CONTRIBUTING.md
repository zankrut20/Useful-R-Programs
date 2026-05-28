# Contributing to Useful R Programs

Thank you for your interest in contributing! This document provides guidelines for reporting issues, submitting code, and participating in the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Reporting Issues](#reporting-issues)
- [Submitting Changes](#submitting-changes)
- [Code Style Guidelines](#code-style-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)
- [Review Process](#review-process)

## 🤝 Code of Conduct

- Be respectful and constructive in all discussions
- Welcome all contributors regardless of background or experience
- Focus on the code, not the person
- Provide helpful feedback and be open to receiving it
- Report inappropriate behavior to the maintainers

## 🚀 Getting Started

### Prerequisites
- R 3.5.0 or later
- Git installed and configured
- GitHub account
- Basic knowledge of R and Git workflows

### Setup Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/Useful-R-Programs.git
   cd Useful-R-Programs
   ```

3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Set up Git hooks** (optional but recommended):
   ```bash
   # Create a pre-commit hook to check your code
   ```

## 🐛 Reporting Issues

### Before Reporting
- Check existing issues to avoid duplicates
- Search closed issues in case it's already been resolved
- Verify the issue occurs with the latest version

### Creating an Issue

Please include:

1. **Clear title** - Briefly describe the issue
2. **Description** - Detailed explanation of the problem
3. **R version** - Output of `R.version`
4. **Environment** - Operating system (Windows/Mac/Linux)
5. **Reproduction steps**:
   ```r
   # Minimal reproducible example
   source("script-name.R")
   function_call()  # What triggers the issue
   ```
6. **Expected behavior** - What should happen
7. **Actual behavior** - What actually happens
8. **Error messages** - Full error output if applicable
9. **Screenshots** - If relevant to the issue

### Issue Labels

- `bug` - Something isn't working
- `enhancement` - Feature request or improvement
- `documentation` - Issues with docs or examples
- `good-first-issue` - Good for newcomers
- `help-wanted` - Extra attention needed
- `question` - General questions

## 📝 Submitting Changes

### 1. Create Your Feature Branch

```bash
git checkout -b feature/descriptive-name
```

Branch naming conventions:
- `feature/` - New functionality
- `fix/` - Bug fix
- `docs/` - Documentation only
- `refactor/` - Code restructuring (no behavior change)
- `test/` - Adding or updating tests

### 2. Make Your Changes

**Single Responsibility**: Each change should address one issue/feature

**Keep it focused**: Avoid mixing unrelated changes

**File organization**: Follow the existing structure

### 3. Test Your Changes

Before submitting:

```r
# Load and test your modified script
source("modified-script.R")

# Test the interactive prompts
function_name()

# Verify no errors or warnings
```

**Important**: Test across different scenarios:
- With valid inputs
- With edge cases
- With invalid/missing inputs
- In a clean R session

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat: Add descriptive message"
```

See [Commit Message Guidelines](#commit-message-guidelines) below.

### 5. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 6. Create a Pull Request

1. Go to GitHub and click "New Pull Request"
2. Select your fork and branch
3. Fill out the PR template with:
   - **Title** - Clear, descriptive title
   - **Description** - What changes, why, and what issues it fixes
   - **Type** - Bug fix, feature, enhancement, documentation
   - **Related Issues** - Link to any related issues (#123)
   - **Checklist** - Confirm you've followed guidelines

### File Organization

Scripts are organized by functionality in the following directories:

**Package Management** (`package-management/`)
- Package removal, auditing, scanning, cleanup

**Memory Management** (`memory-management/`)
- Memory cleanup, cache sweeping, garbage collection

**Development Environment** (`dev-environment/`)
- Git setup, tool bootstrapping, pre-commit hooks, session logging

**Session Management** (`session-management/`)
- State auditing, function masking detection, environment snapshots

**Batch Processing** (`batch-processing/`)
- Memory-safe loops, checkpoint recovery, network operations

**Code Generation** (`code-generation/`)
- Release automation, vignette scaffolding, test generation, clean-room testing

**Privacy** (`privacy/`)
- Data anonymization, PII removal, pseudonymization

**Utilities** (`utilities/`)
- Miscellaneous utilities and specialized tools

When adding new scripts:
1. Choose the most appropriate directory
2. If creating a new category, create a new directory
3. Include a README.md in the directory explaining its contents
4. Update the main README.md with links to your new directory
5. Reference your scripts in the appropriate section

### R Naming Conventions

```r
# Functions: snake_case
my_function <- function() {
  # Code
}

# Variables: snake_case
my_variable <- 123
data_frame <- data.frame()

# Constants: UPPER_SNAKE_CASE
DEFAULT_THRESHOLD <- 50
MAX_ATTEMPTS <- 5
```

### Code Formatting

```r
# Spacing around operators
x <- 1 + 2  # Good
x<-1+2      # Bad

# Function calls
result <- my_function(arg1, arg2)
result <- my_function(
  arg1 = value1,
  arg2 = value2
)

# If statements
if (condition) {
  # Code
} else {
  # Code
}

# Loops
for (i in seq_len(n)) {
  # Code
}
```

### Function Documentation

Add roxygen-style comments:

```r
#' Brief description of function
#'
#' Longer explanation of what the function does, when to use it,
#' and any important side effects.
#'
#' @param arg_name Description of argument
#' @param arg_name2 Description of second argument
#'
#' @return Description of what is returned
#'
#' @examples
#' \dontrun{
#'   my_function(arg_name = value)
#' }
#'
#' @export

my_function <- function(arg_name, arg_name2 = default) {
  # Implementation
}
```

### Comments in Code

```r
# Use clear, descriptive comments
# Explain the "why", not the "what"

# Bad:
x <- x + 1  # Add 1 to x

# Good:
# Increment counter for next iteration
x <- x + 1

# Multi-line comment for complex logic
# Check if threshold exceeded before proceeding
# This prevents unnecessary processing
if (value > threshold) {
  # Process
}
```

### Error Handling

```r
# Include helpful error messages
if (!file.exists(filename)) {
  stop(sprintf("File not found: '%s'. Please check the path.", filename))
}

# Use informative warnings
if (length(items) == 0) {
  warning("No items to process. Returning empty result.")
  return(invisible(NULL))
}

# Use tryCatch for recovery
result <- tryCatch({
  risky_operation()
}, error = function(e) {
  message(sprintf("Error during processing: %s", e$message))
  return(NULL)
})
```

### Interactive Prompts

When using `select.list()` or `readline()`:

```r
# Provide clear prompts
choice <- select.list(
  choices = c("Option A", "Option B", "Cancel"),
  title = "What would you like to do?"
)

# Validate input
threshold <- readline(prompt = "Enter threshold (default: 50): ")
threshold <- suppressWarnings(as.numeric(threshold))
if (is.na(threshold)) {
  message("Invalid input. Using default value of 50.")
  threshold <- 50
}
```

## 📌 Commit Message Guidelines

Use the following format for commit messages:

```
<type>: <subject>

<body>

<footer>
```

### Type
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Code style changes (formatting, missing semicolons, etc.)
- `refactor` - Code refactoring without behavior change
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

### Subject
- Use imperative mood ("add" not "added")
- Don't capitalize first letter
- No period at the end
- Limit to 50 characters

### Body
- Explain what and why, not how
- Wrap at 72 characters
- Separate from subject with blank line
- Use bullet points for multiple changes

### Footer
- Reference issues: `Fixes #123`, `Closes #456`
- Note breaking changes: `BREAKING CHANGE: description`

### Examples

```
feat: add memory_sweeper function

Add interactive function to clean large objects from global environment.
Includes threshold configuration and garbage collection trigger.

Fixes #45
```

```
fix: prevent infinite loop in network_diplomat

Add max_retries check to prevent infinite retry loops
when server is unresponsive.

Closes #78
```

```
docs: update README with usage examples

Add clear examples for each script category to help
new users get started quickly.
```

## 🧪 Testing

### When to Write Tests

- New functions
- Bug fixes (add test that reproduces the bug first)
- Important features
- Edge cases and error conditions

### Test Structure

```r
# Example test structure
test_that("function handles missing input", {
  expect_error(
    my_function(missing_arg),
    "required argument"
  )
})

test_that("function returns expected output", {
  result <- my_function(valid_input)
  expect_type(result, "list")
  expect_length(result, 3)
})
```

### Running Tests

```r
# Assuming testthat is installed
# Test individual file
testthat::test_file("tests/testthat/test-my-script.R")

# Test all tests
testthat::test_dir("tests/testthat")
```

## 📚 Documentation

### README Updates
- Update main README.md to reference new scripts/directories
- Update directory-specific README.md files
- Add usage examples and best practices
- Include links to related scripts in "Related" sections

### Inline Documentation
- Document complex algorithms with comments
- Explain non-obvious design decisions
- Add examples in roxygen comments
- Include before/after examples where applicable

### New Script Checklist
- [ ] Placed in correct directory (or create new one if needed)
- [ ] Descriptive filename (`verb_noun.R`)
- [ ] Header comments explaining purpose
- [ ] Function documentation with roxygen tags
- [ ] Usage examples in comments
- [ ] Error handling with informative messages
- [ ] Interactive prompts for user input
- [ ] Backup warnings for destructive operations
- [ ] Tests in `tests/testthat/` (if applicable)
- [ ] Updated directory-specific README.md
- [ ] Updated main README.md with link to directory
- [ ] Added to CONTRIBUTING.md if creating new category

## 👀 Review Process

### What We Look For

1. **Correctness** - Does it work as intended?
2. **Code Quality** - Follows style guidelines and best practices
3. **Documentation** - Clear comments and function documentation
4. **Testing** - Tested thoroughly, including edge cases
5. **Breaking Changes** - Clearly documented if not backward compatible
6. **Performance** - No unnecessary slowdowns

### Review Feedback

- Maintainers will review within 1-2 weeks
- Constructive feedback will be provided
- Changes may be requested before merging
- Be open to suggestions and iterative improvements

### Merging

- PR must pass all checks
- At least one approval from maintainer
- All conversations resolved
- Branch is up to date with main

## ✅ Submission Checklist

Before submitting your PR, ensure:

- [ ] Code follows style guidelines
- [ ] Changes are well-documented
- [ ] New functions have roxygen comments
- [ ] Error handling is included
- [ ] Tested in clean R session
- [ ] Tested with edge cases
- [ ] No breaking changes (or clearly documented)
- [ ] Commit messages follow guidelines
- [ ] Branch is up to date with main
- [ ] PR description is clear and complete
- [ ] Related issues are linked

## 🙏 Thank You

Your contributions make this project better! Whether it's:
- **Reporting bugs** - Helps identify problems
- **Suggesting features** - Inspires improvements
- **Writing documentation** - Helps others learn
- **Submitting code** - Adds functionality
- **Testing** - Ensures quality

We appreciate all types of contributions!

---

## 📞 Questions?

- Check existing issues and discussions
- Read through this guide thoroughly
- Open a discussion if unsure
- Ask in a new issue (label with `question`)

## 📖 Additional Resources

- [R Style Guide](https://style.tidyverse.org/)
- [Git & GitHub Help](https://docs.github.com/en)
- [roxygen2 Documentation](https://roxygen2.r-lib.org/)
- [Commit Message Best Practices](https://commit.style/)

---

**Happy contributing!** 🎉

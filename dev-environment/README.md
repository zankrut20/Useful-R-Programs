# Development Environment

Scripts for bootstrapping development tools and managing package lifecycle support.

## Contents

- `dev_bootstrap.R` - Install and attach core development packages.
- `manage_deprecation.R` - Scaffold deprecation wrappers and refactor old function usage.
- `setup_preflight.R` - Create a Git pre-commit hook with optional style, docs, and test checks.
- `setup_sentinel.R` - Enable dual logging for messages, warnings, and errors.

## Usage

```r
source("dev-environment/dev_bootstrap.R")
bootstrap_dev_env()

source("dev-environment/manage_deprecation.R")
manage_deprecation()

source("dev-environment/setup_preflight.R")
setup_preflight()

source("dev-environment/setup_sentinel.R")
setup_sentinel()
```

## Notes

- Use `manage_deprecation.R` when maintaining packages and retiring old functions.
- Use pre-commit hooks to automate checks before commits.
- Session logging is helpful for reproducibility and debugging long runs.

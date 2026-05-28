# Code Generation

Scripts for release workflows, vignette scaffolding, test generation, and clean-room verification.

## Contents

- `architect_release.R` - Interactive release scaffolding and version bumping.
- `architect_vignette.R` - Create vignette templates with CRAN-friendly metadata.
- `scaffold_parallel.R` - Generate parallel processing boilerplate.
- `scaffold_tests.R` - Generate test files and templates.
- `simulate_clean_room.R` - Run scripts in a vanilla R session to verify reproducibility.

## Usage

```r
source("code-generation/architect_release.R")
architect_release()

source("code-generation/architect_vignette.R")
architect_vignette()

source("code-generation/scaffold_parallel.R")
scaffold_parallel()

source("code-generation/scaffold_tests.R")
scaffold_tests()

source("code-generation/simulate_clean_room.R")
simulate_clean_room()
```

## Notes

- Use clean-room testing before release or sharing scripts.
- Generate tests and release scaffolding to streamline package workflows.

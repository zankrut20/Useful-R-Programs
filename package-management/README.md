# Package Management

Utilities for package inspection, cleanup, and dependency auditing.

## Contents

- `audit_dependencies.R` - Audit package dependencies against DESCRIPTION and code usage.
- `package-remover.R` - Safe package removal with dependency-aware selection.
- `remove_user_installed_packages.R` - Bulk remove user-installed packages while keeping base/recommended packages.
- `scan_dependencies.R` - Scan loaded packages and identify unused dependencies.

## Usage

```r
source("package-management/audit_dependencies.R")
audit_dependencies()

source("package-management/package-remover.R")
remove("dplyr")

source("package-management/remove_user_installed_packages.R")
# Review script and run carefully.

source("package-management/scan_dependencies.R")
scan_dependencies()
```

## Notes

- Always backup your library before removing packages.
- Use `scan_dependencies.R` to identify packages that may no longer be needed.

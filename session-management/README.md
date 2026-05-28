# Session Management

Tools for auditing R session state, resolving function masking, and exporting package snapshots.

## Contents

- `audit_state.R` - Capture pre/post script state and optionally revert unintended changes.
- `detect_masking.R` - Detect namespace conflicts and suggest resolution strategies.
- `session_snapshot.R` - Export the current attached package snapshot to an installation script.

## Usage

```r
source("session-management/audit_state.R")
audit_script()

source("session-management/detect_masking.R")
detect_masking()

source("session-management/session_snapshot.R")
export_snapshot()
```

## Notes

- Use session auditing before running scripts that may alter global options or graphics state.
- Resolve package masking issues to avoid inconsistent function dispatch.
- Export attached package snapshots for reproducibility.

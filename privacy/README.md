# Privacy

Dataset anonymization tools for protecting personally identifiable information (PII).

## Contents

- `mask_identity.R` - Interactively anonymize or drop sensitive dataset columns.

## Usage

```r
source("privacy/mask_identity.R")
mask_identity()
```

## Notes

- Dropping columns is irreversible in the current session.
- Review all prompts before applying anonymization.

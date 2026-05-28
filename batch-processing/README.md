# Batch Processing

Safe batch and network utilities for long-running R workflows.

## Contents

- `dispatch_checkpoints.R` - Save progress during batch runs and resume after crashes.
- `loop_guardian.R` - Monitor RAM usage and trigger safe recovery during loops.
- `network_diplomat.R` - Rate-limited network requests with retries and exponential backoff.

## Usage

```r
source("batch-processing/dispatch_checkpoints.R")
results <- dispatch_checkpoints(items, target_func, checkpoint_file = "progress.rds")

source("batch-processing/loop_guardian.R")
results <- loop_guardian(items, target_func, limit_mb = 4000)

source("batch-processing/network_diplomat.R")
results <- network_diplomat(urls, fetch_function, max_retries = 3)
```

## Notes

- Use checkpointing for unrecoverable batch jobs.
- Use loop guardian when iterating over large datasets.
- Use network diplomat for API calls that require polite rate limiting.

# Memory Management

Tools for freeing memory, clearing temporary caches, and cleaning hidden workspace artifacts.

## Contents

- `memory_sweeper.R` - Remove large objects from the global environment and run garbage collection.
- `hunt_zombies.R` - Detect hidden temp files, open graphics devices, and orphaned memory.
- `sweep_temp_cache.R` - Clean hidden R temporary directories and caches.

## Usage

```r
source("memory-management/memory_sweeper.R")
sweep_memory()

source("memory-management/hunt_zombies.R")
hunt_zombies()

source("memory-management/sweep_temp_cache.R")
sweep_temp_cache()
```

## Notes

- Run these tools before long sessions or after package installations.
- Use them together to reset session resources and reclaim space.

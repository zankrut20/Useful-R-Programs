# Useful R Programs

A curated collection of practical R scripts organized by purpose. This repository is now structured so that each script lives inside a category folder and includes a per-directory README.

## 📦 Repository Structure

```
Useful-R-Programs/
├── package-management/          # Package and dependency utilities
├── memory-management/           # Memory cleanup and session cache tools
├── dev-environment/             # Development workflow and package lifecycle helpers
├── session-management/          # Session state auditing and masking resolution
├── batch-processing/            # Safe batch and network processing
├── code-generation/             # Release, vignette, scaffolding, and clean-room utilities
├── privacy/                     # Dataset anonymization utilities
├── utilities/                   # Miscellaneous helper tools
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── .gitignore
└── .git
```

## 🚀 Get Started

Source the script you want from its category folder, then call the exported function.

```r
source("package-management/audit_dependencies.R")
audit_dependencies()
```

## 🧭 Categories

- [Package Management](package-management/README.md)
- [Memory Management](memory-management/README.md)
- [Development Environment](dev-environment/README.md)
- [Session Management](session-management/README.md)
- [Batch Processing](batch-processing/README.md)
- [Code Generation](code-generation/README.md)
- [Privacy](privacy/README.md)
- [Utilities](utilities/README.md)

## ⚠️ Important Notes

- All scripts are now organized by usage and purpose.
- Do not run destructive scripts without verifying their behavior first.
- Use the per-directory README for exact script usage.
- `.Rhistory` and temporary cleanup docs have been removed from the repository.

## 📋 Highlights

### Package Management
- `package-remover.R`
- `remove_user_installed_packages.R`
- `audit_dependencies.R`
- `scan_dependencies.R`

### Memory Management
- `memory_sweeper.R`
- `hunt_zombies.R`
- `sweep_temp_cache.R`

### Development Environment
- `dev_bootstrap.R`
- `manage_deprecation.R`
- `setup_preflight.R`
- `setup_sentinel.R`

### Session Management
- `audit_state.R`
- `detect_masking.R`
- `session_snapshot.R`

### Batch Processing
- `loop_guardian.R`
- `dispatch_checkpoints.R`
- `network_diplomat.R`

### Code Generation
- `architect_release.R`
- `architect_vignette.R`
- `scaffold_parallel.R`
- `scaffold_tests.R`
- `simulate_clean_room.R`

### Privacy
- `mask_identity.R`

### Utilities
- `benchmark_branches.R`
- `dictate_dictionary.R`

## 📝 License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.

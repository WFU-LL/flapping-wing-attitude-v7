# Model Package Verification Summary

## Included source

- Core V7/V8 model files: 30
- Reconstruction-robustness MATLAB/Simulink files: 35
- Simulink model files: 4
- MATLAB source and run scripts: 62, including the package path helper

## Model integrity

- `flapping_wing_attitude_plant_v7.slx`: PASS
- `flapping_wing_attitude_plant_v8_compensation.slx`: PASS
- `model_recon_robustness.slx`: PASS
- `model_recon_robustness_ensemble.slx`: PASS

Each `.slx` file opened as a valid ZIP-based Simulink package and contained the expected content-type and block-diagram XML entries.

## Canonical comparison

Of the 30 core model files, 28 have counterparts in the Phase 8 canonical research archive and are SHA-256 identical. The two remaining runtime helpers, `plot_flapping_wing_results_v7.m` and `v6_param.m`, are named in the final root model manifest but were not duplicated in the Phase 8 `02_Models` subarchive; their current root-project copies are included.

## Exclusions

No generated result images, MAT result files, figure files, PDF reports, logs, checkpoints, caches, or obsolete development models are included. Documentation CSV files in this package contain only inventory, hash, and integrity metadata.

## Result

The package is a curated source-model delivery for the current manuscript. The original project files were not modified.

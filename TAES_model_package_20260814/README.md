# TAES Flapping-Wing Attitude Model Package

This directory contains the MATLAB/Simulink source package supplied for the flapping-wing attitude-control study associated with the manuscript *Model Fidelity and Torque-Cost Tradeoffs for Attitude Regulation of Flexible Flapping-Wing Systems*.

## Scope

The package provides:

- a simplified six-state flapping-wing attitude plant and related V7/V8 development models;
- baseline and compensation controllers, disturbance models, parameter initialization, simulation drivers, metric extraction, plotting, and sensitivity-analysis scripts;
- a separate reconstruction-robustness workflow with its MATLAB and Simulink source files; and
- file manifests, SHA-256 records, canonical-copy comparisons, and Simulink-package integrity checks.

The V7/V8 labels are internal development identifiers retained to preserve the original source-code interfaces. They are not manuscript version labels.

## Directory structure

- `Core_V7_V8_Model/`: core MATLAB/Simulink attitude-model source.
- `Reconstruction_Robustness_Model/`: reconstruction-robustness source and batch drivers.
- `Documentation/`: package inventories, hashes, and integrity reports.
- `setup_model_paths.m`: adds both source directories to the MATLAB path.
- `LICENSE`: license file supplied with the source package.

## Getting started

From MATLAB, set this directory as the current folder and run:

```matlab
setup_model_paths
```

Representative entry points include:

```matlab
run_flapping_wing_simulink_comparison_v7
run_v8_deterministic_control_comparison
run_v8_paired_montecarlo
run_recon_robustness
```

MATLAB and Simulink are required. Compatibility should be checked in the MATLAB release used by the reader.

## Reproducibility boundary

This repository directory preserves the source package as supplied. It does not contain generated result images, MAT result files, checkpoints, or the complete raw benchmark data used for every manuscript table and figure. Some workflow scripts also reference project-specific helper functions that are not present in this package; users should verify that all required dependencies are available on the MATLAB path before running a full campaign.

Accordingly, this package should be cited as a source-model archive rather than as a complete one-command reproduction bundle for all manuscript results.


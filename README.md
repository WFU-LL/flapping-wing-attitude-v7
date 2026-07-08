# Flexible Flapping-Wing Attitude Model V7

![Mechanism-oriented framework](assets/github_preview.png)

This repository contains the final V7 deliverables for a simplified mechanism-based Simulink attitude model of a flexible flapping-wing system. The model is intended for mechanism-oriented simulation and publication-figure support, not high-fidelity CFD/FSI flight reproduction.

## Repository Contents

- `model/`
  - `flapping_wing_attitude_plant_v7.slx`: final tuned V7 Simulink plant used for simulation results.
  - `flapping_wing_attitude_plant_v7_framework_refstyle.slx`: top-level framework-style visualization model with unchanged internal logic.
- `src/`
  - MATLAB initialization, dynamics, flexible-force, controller, plotting, comparison, and sensitivity scripts.
- `results/simulation_results_v7/`
  - Four-case V7 simulation results, metrics, reports, and result figures.
- `figures/main_figures/`
  - Final manuscript-oriented main figures.
- `figures/framework/`
  - Final publication framework figure in PNG/PDF/SVG format.
- `docs/`
  - Final technical report, framework equivalence report, and figure-refinement notes.
- `assets/github_preview.png`
  - GitHub README preview image.

## Main Simulation Cases

The V7 comparison includes four cases:

1. `rigid_baseline`
2. `inertia_only`
3. `inertia_flex`
4. `inertia_flex_wake`

## How to Run

Open MATLAB R2025b or a compatible recent MATLAB/Simulink version, then run:

```matlab
cd('path/to/this/repository/src')
addpath(genpath(pwd))
addpath('../model')
run_flapping_wing_simulink_comparison_v7
calculate_flapping_wing_metrics_v7
plot_flapping_wing_results_v7
```

The main model file is:

```text
model/flapping_wing_attitude_plant_v7.slx
```

## Notes

- The V7 model uses a simplified six-state attitude plant.
- Flexible-wing effects are represented as additive equivalent correction moments.
- The framework-style Simulink model is for visualization and documentation; it preserves the tuned V7 internal dynamics, controller, flexible-force functions, and parameters.
- Existing result files are included to support manuscript review and reproducibility checks.

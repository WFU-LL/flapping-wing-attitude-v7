# Final Model File Manifest

## V7 mechanism model

- `flapping_wing_attitude_plant_v7.slx`
- `flapping_wing_attitude_sfun_v7.m`
- `flapping_wing_attitude_dynamics_v7.m`
- `flapping_wing_flexible_forces_v7.m`
- `init_flapping_wing_v7_params.m`
- `build_flapping_wing_attitude_plant_v7.m`
- `run_flapping_wing_simulink_comparison_v7.m`
- `run_v7_case_with_parameter_override.m`
- `extract_v7_simout.m`
- `calculate_flapping_wing_metrics_v7.m`
- `plot_flapping_wing_results_v7.m`
- `sensitivity_sweep_flapping_wing_v7.m`

## V8 selective-compensation model

- `flapping_wing_attitude_plant_v8_compensation.slx`
- `flapping_wing_attitude_sfun_v8.m`
- `flapping_wing_attitude_dynamics_v8.m`
- `flapping_wing_controller_v8.m`
- `flapping_wing_disturbance_moment_v8.m`
- `init_flapping_wing_v8_params.m`
- `build_flapping_wing_attitude_plant_v8.m`
- `run_v8_direct_case.m`
- `run_v8_deterministic_control_comparison.m`
- `run_v8_paired_montecarlo.m`
- `compute_v8_control_metrics.m`
- `extract_v8_simout.m`
- `verify_v8_regression_and_zero_scale.m`

## Shared mechanism functions

- `flapping_wing_attitude_dynamics_v6.m`
- `flapping_wing_flexible_forces_v6.m`
- `flapping_wing_controller_v6.m`
- `init_flapping_wing_v6_params.m`
- `v6_param.m`

## Reconstruction robustness

The complete isolated implementation and final CSV/figure evidence are retained under `reconstruction_robustness_study/`.

## Canonical copies

Versioned paper copies of V7/V8 model files are also retained under `ND_Phase8_Canonical_Research_Archive/02_Models/`.

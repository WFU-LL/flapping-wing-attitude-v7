# V7 Reference-Style Framework Model Description

## Purpose

`flapping_wing_attitude_plant_v7_framework_refstyle.slx` is a reference-image-style top-level restructuring of the tuned V7 Simulink model. It is intended to show the mechanism-oriented framework with explicit command, control, flexible correction, plant, response, feedback, and offline analysis paths.

## Visual Signal Paths

- Blue solid path: reference command, attitude controller, control moment `M_c`, plant, and attitude response output.
- Green solid path: attitude-response state feedback from responses to measured states and back to the controller.
- Magenta solid path: proposed flexible-wing correction module output `Delta M_flex` injected into the plant.
- Gray/black dashed-style analysis path: attitude responses to dynamic response analysis, used only for post-processing documentation.

## Flexible-Wing Correction Module

The module contains 4A Flapping Kinematics, 4B Flapping-Wing Characteristic Information, 4C FSI-Referenced Aerodynamic / Structural Information, 4D Correction Term Generation, 4E Equivalent Force-to-Moment Mapping, and 4F Scalable Correction Gains. These are visual and documentation-level groupings of the existing tuned V7 calculation path.

## Unchanged Internal Model

The following tuned files were not modified by this top-level restructuring:

- `flapping_wing_attitude_dynamics_v7.m`
- `flapping_wing_flexible_forces_v7.m`
- `flapping_wing_controller_v6.m`
- `init_flapping_wing_v7_params.m`

The plant still uses the unchanged `flapping_wing_attitude_sfun_v7` computational core, and the output variable name remains `simout_v7` for downstream script compatibility.

## Equivalence Verification

- `rigid_baseline`: attitude 0.000e+00 deg, rate 0.000e+00 rad/s, moment 0.000e+00 N*m, pass = 1
- `inertia_only`: attitude 0.000e+00 deg, rate 0.000e+00 rad/s, moment 0.000e+00 N*m, pass = 1
- `inertia_flex`: attitude 0.000e+00 deg, rate 0.000e+00 rad/s, moment 0.000e+00 N*m, pass = 1
- `inertia_flex_wake`: attitude 0.000e+00 deg, rate 0.000e+00 rad/s, moment 0.000e+00 N*m, pass = 1

Overall result: **PASS**.

## Use Guidance

Use the refstyle model and screenshots for Methods-section framework explanation and supplementary documentation. Use the original V7 model or this numerically equivalent refstyle model for simulation checks, but do not describe the framework as high-fidelity CFD/FSI or experimental validation.

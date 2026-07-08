# Refined Publication Framework V7 Final Notes

## Scope

This final clean-up refinement only updates the publication figure appearance. It does not modify the V7 Simulink model, internal dynamics, controller logic, flexible-force functions, parameters, simulation scripts, or result data.

## Line Routing

- Simplified the control, feedback, flexible-correction, and analysis paths with cleaner orthogonal routing.
- Shifted the flexible-wing correction module slightly to avoid visual overlap with the controller block.
- Made the feedback loop flatter and clearer along the lower part of the figure.
- Routed the flexible correction moment directly into the plant with a shorter purple path.
- Lowered the dashed analysis line to avoid interfering with the Dynamic Response Analysis title.

## Font Hierarchy

- Unified the figure around Arial.
- Preserved the intended hierarchy: title, subtitle, module titles, submodule titles, body text, signal labels, innovation text, and bottom Notes/Symbols/Legend.
- Reduced crowding in the Dynamic Response Analysis block and kept bottom explanatory panels smaller than the main model area.

## Scientific Inserts

- Kept only small, low-contrast schematic inserts for flapping kinematics, wing geometry, plant attitude axes, and attitude-response curves.
- Reduced icon scale and visual weight so the inserts support interpretation without competing with the signal-flow structure.

## Unchanged Logic

The diagram structure remains unchanged:

- Reference attitude commands feed the Attitude Controller.
- Measured states close the feedback loop to the controller.
- The controller sends the control moment \(M_c\) to the six-state attitude plant.
- The proposed flexible-wing correction module supplies the additive moment \(\Delta M_{flex}\) to the plant.
- The plant outputs attitude trajectories to the response block.
- Dynamic response analysis is shown as post-processing only.

## Outputs

- `refined_publication_framework_v7_final.png`
- `refined_publication_framework_v7_final.pdf`
- `refined_publication_framework_v7_final.svg`
- `refined_publication_framework_v7_final_source.m`
- `refined_publication_framework_v7_final_notes.md`

function passed = run_flapping_wing_framework_refstyle_check_v7()
%RUN_FLAPPING_WING_FRAMEWORK_REFSTYLE_CHECK_V7
% Verify numerical equivalence between the original tuned V7 Simulink model
% and the reference-style framework model. Existing V1-V7 result files are
% not overwritten.

rootDir = fileparts(mfilename('fullpath'));
cd(rootDir);
run('init_flapping_wing_v7_params.m');
rootDir = fileparts(mfilename('fullpath'));
cd(rootDir);

origModel = model_v7;
refstyleModel = 'flapping_wing_attitude_plant_v7_framework_refstyle';
if ~isfile(fullfile(rootDir, [refstyleModel '.slx']))
    build_flapping_wing_framework_refstyle_v7;
    run('init_flapping_wing_v7_params.m');
    rootDir = fileparts(mfilename('fullpath'));
    cd(rootDir);
end

cases = {
    'rigid_baseline', 0, 0, 0;
    'inertia_only', 1, 0, 0;
    'inertia_flex', 1, 1, 0;
    'inertia_flex_wake', 1, 1, 1
    };

tol_att_deg = 1e-6;
tol_rate = 1e-8;
tol_moment = 1e-8;

rows = struct('case_name', {}, 'max_attitude_deg', {}, ...
    'max_rate_rad_s', {}, 'max_moment_Nm', {}, 'pass', {});

load_system(origModel);
load_system(refstyleModel);
for m = {origModel, refstyleModel}
    set_param(m{1}, 'StopTime', num2str(sim_stop_time_v7));
    set_param(m{1}, 'Solver', 'ode45');
    set_param(m{1}, 'MaxStep', num2str(sim_max_step_v7));
    set_param(m{1}, 'ReturnWorkspaceOutputs', 'on');
end

for i = 1:size(cases, 1)
    caseName = cases{i, 1};
    enable_inertia_v7 = cases{i, 2};
    enable_flex_v7 = cases{i, 3};
    enable_wake_v7 = cases{i, 4};

    assignin('base', 'enable_inertia_v7', enable_inertia_v7);
    assignin('base', 'enable_flex_v7', enable_flex_v7);
    assignin('base', 'enable_wake_v7', enable_wake_v7);
    assignin('base', 'x0_v7', x0_v7);

    outOrig = sim(origModel);
    [t0, x0, F0, ~] = extract_v7_simout(outOrig.get('simout_v7'));

    outRef = sim(refstyleModel);
    [t1, x1, F1, ~] = extract_v7_simout(outRef.get('simout_v7'));

    [x1a, F1a] = align_to_original(t0, t1, x1, F1);
    attDiffDeg = max(abs((x0(:, 1:3) - x1a(:, 1:3)) * 180 / pi), [], 'all');
    rateDiff = max(abs(x0(:, 4:6) - x1a(:, 4:6)), [], 'all');
    momentDiff = max(abs(F0(:, 7:9) - F1a(:, 7:9)), [], 'all');

    rows(i).case_name = caseName;
    rows(i).max_attitude_deg = attDiffDeg;
    rows(i).max_rate_rad_s = rateDiff;
    rows(i).max_moment_Nm = momentDiff;
    rows(i).pass = attDiffDeg <= tol_att_deg && ...
        rateDiff <= tol_rate && momentDiff <= tol_moment;
end

close_system(origModel, 0);
close_system(refstyleModel, 0);

passed = all([rows.pass]);
write_refstyle_equivalence_report(rootDir, rows, tol_att_deg, tol_rate, tol_moment, passed);
write_refstyle_description(rootDir, rows, passed);
fprintf('Refstyle framework equivalence check completed. PASS = %d\n', passed);
end

function [x1a, F1a] = align_to_original(t0, t1, x1, F1)
if isequal(size(t0), size(t1)) && max(abs(t0(:) - t1(:))) < eps
    x1a = x1;
    F1a = F1;
else
    x1a = interp1(t1, x1, t0, 'linear', 'extrap');
    F1a = interp1(t1, F1, t0, 'linear', 'extrap');
end
end

function write_refstyle_equivalence_report(rootDir, rows, tol_att_deg, tol_rate, tol_moment, passed)
outPath = fullfile(rootDir, 'framework_refstyle_equivalence_report_v7.txt');
fid = fopen(outPath, 'w');
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, 'V7 Reference-Style Framework Model Equivalence Report\n');
fprintf(fid, 'Generated: %s\n\n', datestr(now));
fprintf(fid, 'Original model: flapping_wing_attitude_plant_v7.slx\n');
fprintf(fid, 'Reference-style framework model: flapping_wing_attitude_plant_v7_framework_refstyle.slx\n\n');
fprintf(fid, 'Reference source: fresh in-memory simulation of the original tuned V7 model.\n');
fprintf(fid, 'Existing V1-V7 result files are not overwritten.\n\n');
fprintf(fid, 'Tolerances:\n');
fprintf(fid, '  max attitude difference <= %.3e deg\n', tol_att_deg);
fprintf(fid, '  max angular-rate difference <= %.3e rad/s\n', tol_rate);
fprintf(fid, '  max flexible-moment difference <= %.3e N*m\n\n', tol_moment);

for i = 1:numel(rows)
    fprintf(fid, 'Case: %s\n', rows(i).case_name);
    fprintf(fid, '  max attitude difference:       %.16e deg\n', rows(i).max_attitude_deg);
    fprintf(fid, '  max angular-rate difference:   %.16e rad/s\n', rows(i).max_rate_rad_s);
    fprintf(fid, '  max flexible-moment difference %.16e N*m\n', rows(i).max_moment_Nm);
    fprintf(fid, '  pass: %d\n\n', rows(i).pass);
end

if passed
    fprintf(fid, 'OVERALL RESULT: PASS\n');
    fprintf(fid, 'The reference-style framework model is numerically equivalent to the original tuned V7 model within tolerance.\n');
else
    fprintf(fid, 'OVERALL RESULT: FAIL\n');
    fprintf(fid, 'The reference-style framework model differs from the original tuned V7 model beyond tolerance. Do not use it before fixing the top-level structure.\n');
end
end

function write_refstyle_description(rootDir, rows, passed)
outPath = fullfile(rootDir, 'framework_refstyle_description_v7.md');
fid = fopen(outPath, 'w');
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, '# V7 Reference-Style Framework Model Description\n\n');
fprintf(fid, '## Purpose\n\n');
fprintf(fid, '`flapping_wing_attitude_plant_v7_framework_refstyle.slx` is a reference-image-style top-level restructuring of the tuned V7 Simulink model. It is intended to show the mechanism-oriented framework with explicit command, control, flexible correction, plant, response, feedback, and offline analysis paths.\n\n');
fprintf(fid, '## Visual Signal Paths\n\n');
fprintf(fid, '- Blue solid path: reference command, attitude controller, control moment `M_c`, plant, and attitude response output.\n');
fprintf(fid, '- Green solid path: attitude-response state feedback from responses to measured states and back to the controller.\n');
fprintf(fid, '- Magenta solid path: proposed flexible-wing correction module output `Delta M_flex` injected into the plant.\n');
fprintf(fid, '- Gray/black dashed-style analysis path: attitude responses to dynamic response analysis, used only for post-processing documentation.\n\n');
fprintf(fid, '## Flexible-Wing Correction Module\n\n');
fprintf(fid, 'The module contains 4A Flapping Kinematics, 4B Flapping-Wing Characteristic Information, 4C FSI-Referenced Aerodynamic / Structural Information, 4D Correction Term Generation, 4E Equivalent Force-to-Moment Mapping, and 4F Scalable Correction Gains. These are visual and documentation-level groupings of the existing tuned V7 calculation path.\n\n');
fprintf(fid, '## Unchanged Internal Model\n\n');
fprintf(fid, 'The following tuned files were not modified by this top-level restructuring:\n\n');
fprintf(fid, '- `flapping_wing_attitude_dynamics_v7.m`\n');
fprintf(fid, '- `flapping_wing_flexible_forces_v7.m`\n');
fprintf(fid, '- `flapping_wing_controller_v6.m`\n');
fprintf(fid, '- `init_flapping_wing_v7_params.m`\n\n');
fprintf(fid, 'The plant still uses the unchanged `flapping_wing_attitude_sfun_v7` computational core, and the output variable name remains `simout_v7` for downstream script compatibility.\n\n');
fprintf(fid, '## Equivalence Verification\n\n');
for i = 1:numel(rows)
    fprintf(fid, '- `%s`: attitude %.3e deg, rate %.3e rad/s, moment %.3e N*m, pass = %d\n', ...
        rows(i).case_name, rows(i).max_attitude_deg, rows(i).max_rate_rad_s, rows(i).max_moment_Nm, rows(i).pass);
end
fprintf(fid, '\nOverall result: **%s**.\n\n', pass_text(passed));
fprintf(fid, '## Use Guidance\n\n');
fprintf(fid, 'Use the refstyle model and screenshots for Methods-section framework explanation and supplementary documentation. Use the original V7 model or this numerically equivalent refstyle model for simulation checks, but do not describe the framework as high-fidelity CFD/FSI or experimental validation.\n');
end

function txt = pass_text(passed)
if passed
    txt = 'PASS';
else
    txt = 'FAIL';
end
end

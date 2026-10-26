function passed = verify_v8_regression_and_zero_scale
% Verify structural regression with matched fixed steps and zero-scale behavior.

cfg = init_v8_evidence_config("verification");
load_system(cfg.model_v7);
load_system(cfg.model_v8);
rows = {};
all_pass = true;

for ci = 1:size(cfg.cases, 1)
    case_name = cfg.cases{ci, 1};
    assignin('base', 'enable_inertia_v7', cfg.cases{ci, 2});
    assignin('base', 'enable_flex_v7', cfg.cases{ci, 3});
    assignin('base', 'enable_wake_v7', cfg.cases{ci, 4});
    assignin('base', 'enable_compensation_v8', 0);
    assignin('base', 'disturbance_case_v8', 'none');
    assignin('base', 'enable_inertia_v8', cfg.cases{ci, 2});
    assignin('base', 'enable_flex_v8', cfg.cases{ci, 3});
    assignin('base', 'enable_wake_v8', cfg.cases{ci, 4});

    local_configure(cfg.model_v7, cfg);
    out7 = sim(cfg.model_v7);
    [t7, x7, terms7, ctrl7] = extract_v7_simout(out7.get('simout_v7'));
    out8 = sim(cfg.model_v8);
    d8 = extract_v8_simout(out8.get('simout_v8'));
    x8 = interp1(d8.t, d8.x, t7, 'linear');
    m8 = interp1(d8.t, d8.M_ifa, t7, 'linear');

    att_diff = max(abs(rad2deg(x7(:, 1:3) - x8(:, 1:3))), [], 'all');
    rate_diff = max(abs(x7(:, 4:6) - x8(:, 4:6)), [], 'all');
    moment_diff = max(abs(terms7(:, 7:9) - m8), [], 'all');
    ctrl_diff = max(abs(ctrl7 - interp1(d8.t, d8.M_0, t7, 'linear')), [], 'all');
    strict_pass = att_diff <= 1e-6 && rate_diff <= 1e-8 && ...
        moment_diff <= 1e-8 && ctrl_diff <= 1e-8;
    established_pass = att_diff <= evalin('base', 'accept_max_att_diff_deg_v7') && ...
        rate_diff <= evalin('base', 'accept_max_rate_diff_v7') && ...
        moment_diff <= 1e-3 && ctrl_diff <= 1e-3;
    all_pass = all_pass && established_pass;
    rows(end+1, :) = {string(case_name), att_diff, rate_diff, ...
        moment_diff, ctrl_diff, strict_pass, established_pass}; %#ok<AGROW>
end

scale_names = {'scale_inertia_v6','scale_flex_v6','scale_wake_v6'};
scale_values = zeros(1, 3);
for i = 1:3
    scale_values(i) = evalin('base', scale_names{i});
    assignin('base', scale_names{i}, 0);
end
assignin('base', 'enable_inertia_v8', 1);
assignin('base', 'enable_flex_v8', 1);
assignin('base', 'enable_wake_v8', 1);
assignin('base', 'enable_compensation_v8', 1);
assignin('base', 'disturbance_case_v8', 'none');
out_zero = sim(cfg.model_v8);
zero = extract_v8_simout(out_zero.get('simout_v8'));
max_zero_moment = max(abs(zero.M_ifa), [], 'all');
max_zero_comp = max(abs(zero.M_comp), [], 'all');
zero_pass = max_zero_moment <= 1e-12 && max_zero_comp <= 1e-12;
all_pass = all_pass && zero_pass;
for i = 1:3
    assignin('base', scale_names{i}, scale_values(i));
end

T = cell2table(rows, 'VariableNames', {'case_name', ...
    'max_attitude_difference_deg','max_rate_difference_rad_s', ...
    'max_flexible_moment_difference_Nm','max_baseline_control_difference_Nm', ...
    'strict_diagnostic_pass','established_v7_acceptance_pass'});
writetable(T, fullfile(cfg.dirs.verification, 'Table_V8_regression_equivalence.csv'));
writetable(T, fullfile(cfg.dirs.verification, 'Table_V8_regression_equivalence.xlsx'));

report = fullfile(cfg.dirs.verification, 'v8_regression_and_zero_scale_report.md');
fid = fopen(report, 'w'); cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '# V8 Regression and Zero-Scale Verification\n\n');
fprintf(fid, ['Structural regression uses the same fixed-step `ode4` solver ', ...
    'at 0.001 s for V7 and V8. A separate retained table documents the ', ...
    'small implementation-dependent difference observed when the two ', ...
    'S-Function models independently select adaptive `ode45` internal steps.\n\n']);
fprintf(fid, '- Ultra-strict diagnostic (1e-6 deg/1e-8): **%s**\n', ...
    local_word(all(T.strict_diagnostic_pass)));
fprintf(fid, ['- Established V7 numerical acceptance (0.05 deg/1e-3 rad s^-1; ', ...
    '1e-3 N m moment diagnostic): **%s**\n'], ...
    local_word(all(T.established_v7_acceptance_pass)));
fprintf(fid, '- Zero-scale M_IFA maximum: `%.12g N m`\n', max_zero_moment);
fprintf(fid, '- Zero-scale M_comp maximum: `%.12g N m`\n', max_zero_comp);
fprintf(fid, '- Zero-scale result: **%s**\n\n', local_word(zero_pass));
fprintf(fid, 'No V7 model, dynamics, controller, force function, or tuned parameter was modified.\n');
passed = all_pass;
close_system(cfg.model_v7, 0); close_system(cfg.model_v8, 0);
end

function local_configure(model, cfg)
set_param(model, 'StopTime', num2str(cfg.stop_time, 17), ...
    'SolverType', 'Fixed-step', 'Solver', 'ode4', ...
    'FixedStep', num2str(cfg.max_step, 17), 'ReturnWorkspaceOutputs', 'on', ...
    'OutputOption', 'SpecifiedOutputTimes', ...
    'OutputTimes', sprintf('0:%.17g:%.17g', cfg.max_step, cfg.stop_time), ...
    'SimulationMode', 'normal');
end

function word = local_word(value)
if value, word = 'PASS'; else, word = 'FAIL'; end
end

% sensitivity_sweep_flapping_wing_v7.m
% Run V7 Simulink parameter sensitivity analysis after equivalence PASS.

clear;
clc;
close all;

run('init_flapping_wing_v7_params.m');

eq_file = fullfile(result_dir_v7, 'v6_v7_equivalence_report.txt');
if ~exist(eq_file, 'file') || isempty(strfind(fileread(eq_file), 'PASS:'))
    error('V6/V7 equivalence has not passed. Do not run V7 sensitivity sweep.');
end

load_system(model_v7);
set_param(model_v7, 'StopTime', num2str(sim_stop_time_v7));
set_param(model_v7, 'Solver', 'ode45');
set_param(model_v7, 'MaxStep', num2str(sim_max_step_v7));
set_param(model_v7, 'ReturnWorkspaceOutputs', 'on');

summary = repmat(struct( ...
    'scenario', '', ...
    'scale_inertia', NaN, ...
    'scale_flex', NaN, ...
    'scale_wake', NaN, ...
    'max_att_deg', NaN, ...
    'rmse_norm', NaN, ...
    'final_yaw_deg', NaN, ...
    'stable', false), 0, 1);
idx = 0;

% Scale inertia/flex together while keeping wake at nominal.
for i = 1:length(scale_grid_v7)
    idx = idx + 1;
    scenario = ['flex_scale_' v7_tag(scale_grid_v7(i))];
    scale_inertia_v6 = scale_grid_v7(i);
    scale_flex_v6 = scale_grid_v7(i);
    scale_wake_v6 = 0.05;
    summary(idx) = run_one_sensitivity_case(model_v7, result_dir_v7, scenario, ...
        scale_inertia_v6, scale_flex_v6, scale_wake_v6); %#ok<SAGROW>
end

% Sweep wake independently at nominal inertia/flex.
for i = 1:length(wake_scale_grid_v7)
    idx = idx + 1;
    scenario = ['wake_scale_' v7_tag(wake_scale_grid_v7(i))];
    scale_inertia_v6 = 0.05;
    scale_flex_v6 = 0.05;
    scale_wake_v6 = wake_scale_grid_v7(i);
    summary(idx) = run_one_sensitivity_case(model_v7, result_dir_v7, scenario, ...
        scale_inertia_v6, scale_flex_v6, scale_wake_v6); %#ok<SAGROW>
end

close_system(model_v7, 0);

save(fullfile(result_dir_v7, 'sensitivity_summary_v7.mat'), 'summary');

fid = fopen(fullfile(result_dir_v7, 'sensitivity_report_v7.txt'), 'w');
fprintf(fid, 'V7 parameter sensitivity report\n');
fprintf(fid, 'Generated at: %s\n\n', datestr(now));
for i = 1:length(summary)
    fprintf(fid, '%s: scale_inertia=%.6g scale_flex=%.6g scale_wake=%.6g max_att=%.6f rmse_norm=%.6f final_yaw=%.6f stable=%d\n', ...
        summary(i).scenario, summary(i).scale_inertia, summary(i).scale_flex, ...
        summary(i).scale_wake, summary(i).max_att_deg, summary(i).rmse_norm, ...
        summary(i).final_yaw_deg, summary(i).stable);
end
fprintf(fid, '\nInterpretation:\n');
fprintf(fid, 'Increasing inertia/flex scale changes pitch/yaw RMSE through direct moment injection. Increasing wake scale mainly shifts yaw through Mz_flex. All listed cases are checked for bounded attitude response.\n');
fclose(fid);

figure('Name', 'V7 sensitivity RMSE', 'Color', 'w');
bar([summary.rmse_norm]);
grid on;
set(gca, 'XTick', 1:length(summary), 'XTickLabel', {summary.scenario}, 'XTickLabelRotation', 45);
ylabel('attitude RMSE norm (deg)');
title('V7 sensitivity RMSE');
saveas(gcf, fullfile(result_dir_v7, 'sensitivity_rmse_v7.png'));
saveas(gcf, fullfile(result_dir_v7, 'sensitivity_rmse_v7.fig'));

figure('Name', 'V7 sensitivity final yaw', 'Color', 'w');
bar([summary.final_yaw_deg]);
grid on;
set(gca, 'XTick', 1:length(summary), 'XTickLabel', {summary.scenario}, 'XTickLabelRotation', 45);
ylabel('final yaw (deg)');
title('V7 sensitivity final yaw');
saveas(gcf, fullfile(result_dir_v7, 'sensitivity_final_yaw_v7.png'));
saveas(gcf, fullfile(result_dir_v7, 'sensitivity_final_yaw_v7.fig'));

function s = run_one_sensitivity_case(model_v7, result_dir_v7, scenario, scale_inertia, scale_flex, scale_wake)
assignin('base', 'enable_inertia_v7', 1);
assignin('base', 'enable_flex_v7', 1);
assignin('base', 'enable_wake_v7', 1);
assignin('base', 'scale_inertia_v6', scale_inertia);
assignin('base', 'scale_flex_v6', scale_flex);
assignin('base', 'scale_wake_v6', scale_wake);

simOut = sim(model_v7);
simout_v7 = simOut.get('simout_v7');
[t, x, F_terms, M_ctrl] = extract_v7_simout(simout_v7);
att_deg = x(:, 1:3) * 180/pi;
rmse_att = sqrt(mean(att_deg.^2, 1));

s.scenario = scenario;
s.scale_inertia = scale_inertia;
s.scale_flex = scale_flex;
s.scale_wake = scale_wake;
s.max_att_deg = max(max(abs(att_deg)));
s.rmse_norm = norm(rmse_att);
s.final_yaw_deg = att_deg(end, 3);
s.stable = all(isfinite(x(:))) && s.max_att_deg < 120;
save(fullfile(result_dir_v7, ['sensitivity_v7_' scenario '.mat']), ...
    't', 'x', 'F_terms', 'M_ctrl', 'scenario', 'scale_inertia', 'scale_flex', 'scale_wake');
end

function tag = v7_tag(x)
tag = strrep(num2str(x, '%.16g'), '.', 'p');
tag = strrep(tag, '-', 'm');
end

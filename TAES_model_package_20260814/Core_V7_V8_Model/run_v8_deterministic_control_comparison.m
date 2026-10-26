function summary = run_v8_deterministic_control_comparison
% Matched direct-Simulink baseline-versus-compensation evidence.

cfg = init_v8_evidence_config("deterministic");
raw = struct();
rows = {};
names = {'case_name','controller_mode','disturbance_case', ...
    'tracking_rmse_norm_deg','max_attitude_deg','final_residual_deg', ...
    'rate_energy','control_energy','compensation_energy','saturation_fraction', ...
    'estimator_rmse_Nm','peak_disturbance_deviation_deg', ...
    'post_disturbance_iae_deg_s','recovery_time_s', ...
    'final_disturbance_residual_deg','simulation_runtime_sec'};
load_system(cfg.model_v8);
set_param(cfg.model_v8, 'SolverType', 'Variable-step', ...
    'StopTime', num2str(cfg.stop_time, 17), 'Solver', 'ode45', ...
    'MaxStep', num2str(cfg.max_step, 17), 'ReturnWorkspaceOutputs', 'on', ...
    'OutputOption', 'SpecifiedOutputTimes', ...
    'OutputTimes', sprintf('0:%.17g:%.17g', cfg.max_step, cfg.stop_time), ...
    'SimulationMode', 'normal', 'FastRestart', 'on');

for ci = 1:size(cfg.cases, 1)
    case_name = cfg.cases{ci, 1};
    for mi = 1:size(cfg.controller_modes, 1)
        mode_name = cfg.controller_modes{mi, 1};
        nominal = run_v8_direct_case(cfg, case_name, mode_name, 'none', struct());
        raw.(case_name).(mode_name).none = nominal;
        m = compute_v8_control_metrics(nominal, [], cfg);
        rows(end+1, :) = local_row(case_name, mode_name, 'none', m, nominal.runtime_sec); %#ok<AGROW>
        local_checkpoint(nominal, rows, names, cfg);
        for di = 2:numel(cfg.disturbances)
            disturbance = cfg.disturbances{di};
            disturbed = run_v8_direct_case(cfg, case_name, mode_name, disturbance, struct());
            raw.(case_name).(mode_name).(disturbance) = disturbed;
            m = compute_v8_control_metrics(disturbed, nominal, cfg);
            rows(end+1, :) = local_row(case_name, mode_name, disturbance, m, disturbed.runtime_sec); %#ok<AGROW>
            local_checkpoint(disturbed, rows, names, cfg);
        end
    end
end

summary = cell2table(rows, 'VariableNames', names);
save(fullfile(cfg.dirs.raw, 'v8_deterministic_control_comparison.mat'), 'raw', 'summary', 'cfg', '-v7.3');
writetable(summary, fullfile(cfg.dirs.tables, 'Table_V8_deterministic_control_comparison.csv'));
writetable(summary, fullfile(cfg.dirs.tables, 'Table_V8_deterministic_control_comparison.xlsx'));
local_report(summary, cfg);
set_param(cfg.model_v8, 'FastRestart', 'off');
close_system(cfg.model_v8, 0);
end

function local_checkpoint(result, rows, names, cfg)
tag = sprintf('%s__%s__%s', result.case_name, ...
    result.controller_mode, result.disturbance_case);
save(fullfile(cfg.dirs.raw, ['result_v8_' tag '.mat']), 'result', '-v7.3');
checkpoint = cell2table(rows, 'VariableNames', names);
writetable(checkpoint, fullfile(cfg.dirs.checkpoints, ...
    'deterministic_control_comparison_checkpoint.csv'));
end

function row = local_row(case_name, mode_name, disturbance, m, runtime_sec)
row = {string(case_name), string(mode_name), string(disturbance), ...
    m.tracking_rmse_norm_deg, m.max_attitude_deg, m.final_residual_deg, ...
    m.rate_energy, m.control_energy, m.compensation_energy, m.saturation_fraction, ...
    m.estimator_rmse_Nm, m.peak_disturbance_deviation_deg, ...
    m.post_disturbance_iae_deg_s, m.recovery_time_s, ...
    m.final_disturbance_residual_deg, runtime_sec};
end

function local_report(T, cfg)
fid = fopen(fullfile(cfg.dirs.reports, 'v8_deterministic_control_comparison_report.md'), 'w');
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '# V8 Deterministic Control Comparison\n\n');
fprintf(fid, 'All trajectories were generated directly by `sim(%s)`.\n\n', cfg.model_v8);
fprintf(fid, '| Case | Disturbance | RMSE change (%%) | IAE change (%%) | Control-energy ratio |\n');
fprintf(fid, '|---|---|---:|---:|---:|\n');
for ci = 1:size(cfg.cases, 1)
    for di = 2:numel(cfg.disturbances)
        c = string(cfg.cases{ci, 1}); d = string(cfg.disturbances{di});
        b = T(T.case_name == c & T.controller_mode == "baseline_pd" & T.disturbance_case == d, :);
        a = T(T.case_name == c & T.controller_mode == "coupling_compensation" & T.disturbance_case == d, :);
        rmse_change = 100 * (a.tracking_rmse_norm_deg / b.tracking_rmse_norm_deg - 1);
        iae_change = 100 * (a.post_disturbance_iae_deg_s / b.post_disturbance_iae_deg_s - 1);
        energy_ratio = a.control_energy / b.control_energy;
        fprintf(fid, '| %s | %s | %.4f | %.4f | %.6f |\n', c, d, rmse_change, iae_change, energy_ratio);
    end
end
fprintf(fid, '\nThis is simulation-based controller comparison, not experimental validation.\n');
end

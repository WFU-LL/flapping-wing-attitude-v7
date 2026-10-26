function run_stage0_regression()
% Verify exact reconstruction against the protected V8 implementation.

cfg = init_recon_robustness_config();
build_recon_robustness_model();
samples = readtable(cfg.sample_file);
sample = samples(1,:);
overrides = v8_sample_overrides(sample);

original_cfg = init_v8_evidence_config('recon_stage0');
original_cfg.max_step = cfg.max_step;
original_cfg.output_times = cfg.output_times;
assignin('base','Kcomp_mifa_v8',[0.3;0;0.3]);

scenario = struct('k',0.3,'delta',zeros(3,1),'delay_ms',0, ...
    'noise_rms_fraction',0,'filter_cutoff_hz',20);
cases = {'inertia-flex','inertia-flex-wake'};
external = {'yaw_impulse','multi_axis_sine'};
rows = table();

for ci = 1:numel(cases)
    original_case = strrep(cases{ci},'-','_');
    for ei = 1:numel(external)
        original = run_v8_direct_case(original_cfg, original_case, ...
            'coupling_compensation', external{ei}, overrides);
        candidate = run_recon_robustness_case(cfg, sample, cases{ci}, ...
            external{ei}, 'C1_selective', scenario);

        t = candidate.t;
        original_x = interp1(original.t, original.x, t, 'linear');
        original_comp = interp1(original.t, original.M_comp, t, 'linear');
        mo = compute_v8_control_metrics(original, [], original_cfg);
        mn = compute_recon_robustness_metrics(candidate, []);

        rel_rmse = local_relative(mn.rmse_norm_deg, mo.tracking_rmse_norm_deg);
        rel_energy = local_relative(mn.control_energy_total, mo.control_energy);
        rel_rate = local_relative(mn.rate_energy, mo.rate_energy);
        rel_yaw = local_relative(mn.final_yaw_deg, rad2deg(original.x(end,3)));
        max_rel_metric = max([rel_rmse rel_energy rel_rate rel_yaw]);
        max_attitude_difference_deg = max(abs(rad2deg( ...
            candidate.x(:,1:3)-original_x(:,1:3))),[],'all');
        max_rate_difference = max(abs( ...
            candidate.x(:,4:6)-original_x(:,4:6)),[],'all');
        max_compensation_difference = max(abs( ...
            candidate.M_comp-original_comp),[],'all');
        pass = max_rel_metric <= 1e-4;
        row = table(string(cases{ci}),string(external{ei}), ...
            rel_rmse,rel_energy,rel_rate,rel_yaw,max_rel_metric, ...
            max_attitude_difference_deg,max_rate_difference, ...
            max_compensation_difference,pass, ...
            'VariableNames',{'mechanism_case','external_condition', ...
            'relative_rmse_error','relative_control_energy_error', ...
            'relative_rate_energy_error','relative_final_yaw_error', ...
            'max_relative_metric_error','max_attitude_difference_deg', ...
            'max_rate_difference_rad_s','max_compensation_difference_Nm', ...
            'pass'});
        rows = [rows;row]; %#ok<AGROW>
        fprintf('STAGE0_PROGRESS case=%s disturbance=%s pass=%d max_rel=%.3e\n', ...
            cases{ci},external{ei},pass,max_rel_metric);
    end
end

out_csv = fullfile(cfg.dirs.verification,'stage0_regression_results.csv');
writetable(rows,out_csv);
overall_pass = all(rows.pass);
report_file = fullfile(cfg.dirs.verification,'stage0_regression_report.md');
fid = fopen(report_file,'w');
fprintf(fid,'# Stage 0 Exact-Reconstruction Regression\n\n');
fprintf(fid,'- Protected reference: `%s.slx`\n',cfg.source_model);
fprintf(fid,'- Candidate copy: `%s.slx`\n',cfg.model);
fprintf(fid,'- Gain: `diag(0.30, 0, 0.30)`\n');
fprintf(fid,'- Bias/delay/noise: zero; LPF disabled.\n');
fprintf(fid,'- Required maximum relative metric error: `1e-4`.\n');
fprintf(fid,'- Observed maximum relative metric error: `%.12g`.\n', ...
    max(rows.max_relative_metric_error));
fprintf(fid,'- STAGE 0 RESULT: **%s**\n',local_word(overall_pass));
fclose(fid);
save(fullfile(cfg.dirs.verification,'stage0_regression_results.mat'), ...
    'rows','overall_pass','scenario','-v7.3');
if bdIsLoaded(original_cfg.model_v8)
    close_system(original_cfg.model_v8, 0);
end
if bdIsLoaded(cfg.model)
    close_system(cfg.model, 0);
end
if ~overall_pass
    error('ReconStudy:Stage0Failed', ...
        'Stage 0 exact-reconstruction regression failed; pilot is blocked.');
end
fprintf('STAGE0_RESULT=PASS max_relative_error=%.3e\n', ...
    max(rows.max_relative_metric_error));
end

function value = local_relative(a,b)
value = abs(a-b)/max(abs(b),eps);
end

function word = local_word(value)
if value, word='PASS'; else, word='FAIL'; end
end

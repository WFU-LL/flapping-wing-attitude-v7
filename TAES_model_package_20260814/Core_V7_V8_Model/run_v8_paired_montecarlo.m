function rows = run_v8_paired_montecarlo
% Paired direct-Simulink N=30 evidence for the two affected coupling cases.

cfg = init_v8_evidence_config("paired_montecarlo");
samples = sfe_generate_samples(cfg, cfg.n_paired);
case_names = {'inertia_flex','inertia_flex_wake'};
disturbances = {'yaw_impulse','multi_axis_sine'};
rows = table(); errors = table();

pool = gcp('nocreate');
if isempty(pool)
    pool = parpool('Processes', 4);
end
futures = parallel.FevalFuture.empty(0, 1);
meta = cell(0, 3);
for si = 1:height(samples)
    for ci = 1:numel(case_names)
        for di = 1:numel(disturbances)
            futures(end+1, 1) = parfeval(pool, @v8_worker_control_pair, 1, ...
                samples(si, :), case_names{ci}, disturbances{di}); %#ok<AGROW>
            meta(end+1, :) = {samples.sample_id(si), case_names{ci}, disturbances{di}}; %#ok<AGROW>
        end
    end
end

for completed = 1:numel(futures)
    [idx, payload] = fetchNext(futures);
    if payload.ok
        rows = [rows; payload.rows]; %#ok<AGROW>
    else
        errors = [errors; table(meta{idx, 1}, string(meta{idx, 2}), ...
            string(meta{idx, 3}), string(payload.error_message), ...
            'VariableNames', {'sample_id','case_name','disturbance_case','error_message'})]; %#ok<AGROW>
    end
    if mod(completed, cfg.checkpoint_interval) == 0 || completed == numel(futures)
        writetable(rows, fullfile(cfg.dirs.checkpoints, 'v8_paired_N30_checkpoint.csv'));
        writetable(errors, fullfile(cfg.dirs.checkpoints, 'v8_paired_N30_errors.csv'));
        fprintf('V8 paired tasks completed: %d/%d, rows=%d, errors=%d\n', ...
            completed, numel(futures), height(rows), height(errors));
    end
end

rows = sortrows(rows, {'case_name','disturbance_case','sample_id','controller_mode'});
save(fullfile(cfg.dirs.paired_montecarlo, 'v8_paired_N30_results.mat'), ...
    'rows', 'errors', 'samples', 'cfg', '-v7.3');
writetable(rows, fullfile(cfg.dirs.tables, 'Table_V8_paired_N30_samples.csv'));
writetable(rows, fullfile(cfg.dirs.tables, 'Table_V8_paired_N30_samples.xlsx'));
writetable(errors, fullfile(cfg.dirs.tables, 'Table_V8_paired_N30_errors.csv'));
end


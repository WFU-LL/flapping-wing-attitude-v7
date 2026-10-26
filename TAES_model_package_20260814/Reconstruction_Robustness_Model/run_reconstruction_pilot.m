function run_reconstruction_pilot()
% Run the complete Stage 2-7 design for matched samples 1:20.

cfg = init_recon_robustness_config();
verification = fullfile(cfg.dirs.verification,'stage0_regression_results.csv');
if ~exist(verification,'file')
    error('ReconStudy:Stage0Missing','Run Stage 0 before the pilot.');
end
stage0 = readtable(verification);
if ~all(stage0.pass)
    error('ReconStudy:Stage0Failed','Stage 0 did not pass.');
end

samples = readtable(cfg.sample_file);
samples = samples(1:cfg.pilot_n,:);
equivalence = fullfile(cfg.dirs.verification, ...
    'ensemble_single_equivalence_results.csv');
if ~exist(equivalence,'file') || ~all(readtable(equivalence).pass)
    error('ReconStudy:EnsembleEquivalenceMissing', ...
        'The batched-versus-single Simulink equivalence check must pass first.');
end
jobs = make_recon_ensemble_jobs(cfg);
checkpoint_file = fullfile(cfg.dirs.checkpoints,'pilot_checkpoint.mat');
csv_file = fullfile(cfg.output_dir,'pilot_run_level_results.csv');

completed_job_ids = zeros(0,1);
all_rows = table();
if exist(checkpoint_file,'file')
    saved = load(checkpoint_file,'completed_job_ids','all_rows');
    completed_job_ids = saved.completed_job_ids;
    all_rows = saved.all_rows;
end
remaining = jobs(~ismember(jobs.job_id,completed_job_ids),:);

pool = gcp('nocreate');
if isempty(pool), pool=parpool('Processes',4); end %#ok<NASGU>
chunk_size = cfg.checkpoint_interval;
for first = 1:chunk_size:height(remaining)
    last = min(first+chunk_size-1,height(remaining));
    current = remaining(first:last,:);
    payloads = cell(height(current),1);
    parfor i = 1:height(current)
        payloads{i} = recon_ensemble_worker_job(current(i,:),samples);
    end
    for i = 1:numel(payloads)
        all_rows = [all_rows;payloads{i}.rows]; %#ok<AGROW>
        completed_job_ids(end+1,1) = current.job_id(i); %#ok<AGROW>
    end
    save(checkpoint_file,'completed_job_ids','all_rows','jobs','-v7.3');
    writetable(all_rows,csv_file);
    fprintf('PILOT_PROGRESS jobs=%d/%d rows=%d failures=%d\n', ...
        numel(completed_job_ids),height(jobs),height(all_rows), ...
        sum(~all_rows.solver_success));
end

expected_rows = height(jobs)*cfg.pilot_n*3;
finite_metrics = all(isfinite(all_rows.rmse_norm_deg(all_rows.solver_success)));
sample_match = isequal(sort(unique(all_rows.sample_id)).',(1:cfg.pilot_n));
pilot_pass = height(all_rows)==expected_rows && ...
    all(all_rows.solver_success) && finite_metrics && sample_match;

report_file = fullfile(cfg.dirs.verification,'pilot_report.md');
fid=fopen(report_file,'w');
fprintf(fid,'# N=20 Reconstruction Robustness Pilot\n\n');
fprintf(fid,'- Direct Simulink trajectories: %d\n',height(all_rows));
fprintf(fid,'- Batched direct-Simulink calls: %d\n',height(jobs)*3);
fprintf(fid,'- Matched scenario/controller groups: %d\n',height(jobs));
fprintf(fid,'- Successful trajectories: %d\n',sum(all_rows.solver_success));
fprintf(fid,'- Failed trajectories: %d\n',sum(~all_rows.solver_success));
fprintf(fid,'- Sample IDs complete and matched: %d\n',sample_match);
fprintf(fid,'- Finite successful-run metrics: %d\n',finite_metrics);
fprintf(fid,'- PILOT RESULT: **%s**\n',local_word(pilot_pass));
fclose(fid);
save(fullfile(cfg.dirs.verification,'pilot_qc.mat'),'pilot_pass', ...
    'expected_rows','sample_match','finite_metrics','-v7.3');
if bdIsLoaded(cfg.model),close_system(cfg.model,0);end
pool=gcp('nocreate');if ~isempty(pool),delete(pool);end
if ~pilot_pass
    error('ReconStudy:PilotFailed','N=20 pilot failed QC; N=100 is blocked.');
end
fprintf('PILOT_RESULT=PASS rows=%d\n',height(all_rows));
end

function word=local_word(value)
if value,word='PASS';else,word='FAIL';end
end

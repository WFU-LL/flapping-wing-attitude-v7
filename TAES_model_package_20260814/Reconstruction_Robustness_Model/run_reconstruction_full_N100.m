function run_reconstruction_full_N100()
% Run the complete Stage 2-7 design for all 100 protected matched samples.

cfg=init_recon_robustness_config();
pilot_qc=fullfile(cfg.dirs.verification,'pilot_qc.mat');
if ~exist(pilot_qc,'file'),error('ReconStudy:PilotMissing','Pilot QC is missing.');end
pilot=load(pilot_qc,'pilot_pass');
if ~pilot.pilot_pass,error('ReconStudy:PilotFailed','Pilot did not pass.');end

samples=readtable(cfg.sample_file);samples=samples(1:cfg.full_n,:);
jobs=make_recon_ensemble_jobs(cfg);
checkpoint_file=fullfile(cfg.dirs.checkpoints,'full_N100_checkpoint.mat');
csv_file=fullfile(cfg.output_dir,'run_level_results_stage2_to_7.csv');
completed_job_ids=zeros(0,1);all_rows=table();
if exist(checkpoint_file,'file')
    saved=load(checkpoint_file,'completed_job_ids','all_rows');
    completed_job_ids=saved.completed_job_ids;all_rows=saved.all_rows;
end
remaining=jobs(~ismember(jobs.job_id,completed_job_ids),:);

pool=gcp('nocreate');if isempty(pool),pool=parpool('Processes',4);end %#ok<NASGU>
chunk_size=cfg.checkpoint_interval;
for first=1:chunk_size:height(remaining)
    last=min(first+chunk_size-1,height(remaining));
    current=remaining(first:last,:);payloads=cell(height(current),1);
    parfor i=1:height(current)
        payloads{i}=recon_ensemble_worker_job(current(i,:),samples);
    end
    for i=1:numel(payloads)
        all_rows=[all_rows;payloads{i}.rows]; %#ok<AGROW>
        completed_job_ids(end+1,1)=current.job_id(i); %#ok<AGROW>
    end
    save(checkpoint_file,'completed_job_ids','all_rows','jobs','-v7.3');
    writetable(all_rows,csv_file);
    fprintf('FULL_N100_PROGRESS groups=%d/%d trajectories=%d failures=%d\n', ...
        numel(completed_job_ids),height(jobs),height(all_rows), ...
        sum(~all_rows.solver_success));
end

expected_rows=height(jobs)*cfg.full_n*3;
finite_metrics=all(isfinite(all_rows.rmse_norm_deg(all_rows.solver_success)));
sample_match=isequal(sort(unique(all_rows.sample_id)).',(1:cfg.full_n));
full_pass=height(all_rows)==expected_rows && all(all_rows.solver_success) ...
    && finite_metrics && sample_match;
fid=fopen(fullfile(cfg.dirs.verification,'full_N100_report.md'),'w');
fprintf(fid,'# N=100 Reconstruction Robustness Campaign\n\n');
fprintf(fid,'- Direct Simulink trajectories: %d\n',height(all_rows));
fprintf(fid,'- Batched direct-Simulink calls: %d\n',height(jobs)*3);
fprintf(fid,'- Successful trajectories: %d\n',sum(all_rows.solver_success));
fprintf(fid,'- Failed trajectories: %d\n',sum(~all_rows.solver_success));
fprintf(fid,'- Sample IDs complete and matched: %d\n',sample_match);
fprintf(fid,'- FULL N=100 RESULT: **%s**\n',local_word(full_pass));
fclose(fid);
save(fullfile(cfg.dirs.verification,'full_N100_qc.mat'),'full_pass', ...
    'expected_rows','sample_match','finite_metrics','-v7.3');
pool=gcp('nocreate');if ~isempty(pool),delete(pool);end
if ~full_pass,error('ReconStudy:FullFailed','N=100 campaign failed QC.');end
fprintf('FULL_N100_RESULT=PASS trajectories=%d\n',height(all_rows));
end

function word=local_word(value)
if value,word='PASS';else,word='FAIL';end
end

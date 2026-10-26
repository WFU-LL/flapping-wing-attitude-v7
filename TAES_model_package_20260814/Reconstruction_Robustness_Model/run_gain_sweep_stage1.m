function run_gain_sweep_stage1()
% Run Stage 1 at nominal parameters and nominal initial conditions.

cfg=init_recon_robustness_config();jobs=make_gain_sweep_jobs(cfg);
sample=table(0,cfg.nominal.Jx,cfg.nominal.Jy,cfg.nominal.Jz, ...
    cfg.nominal.Dx,cfg.nominal.Dy,cfg.nominal.Dz, ...
    cfg.nominal.scale_inertia_v6,cfg.nominal.scale_flex_v6, ...
    cfg.nominal.scale_wake_v6,cfg.nominal.f_flap,cfg.nominal.A0, ...
    5,8,5,0,0,0,'VariableNames',{'sample_id','Jx','Jy','Jz','Dx','Dy','Dz', ...
    'scale_inertia_v6','scale_flex_v6','scale_wake_v6','f_flap','A0', ...
    'initial_roll_deg','initial_pitch_deg','initial_yaw_deg', ...
    'initial_p','initial_q','initial_r'});
checkpoint_file=fullfile(cfg.dirs.checkpoints,'stage1_gain_checkpoint.mat');
csv_file=fullfile(cfg.output_dir,'gain_sweep_run_level_results.csv');
completed_job_ids=zeros(0,1);all_rows=table();
if exist(checkpoint_file,'file')
    saved=load(checkpoint_file,'completed_job_ids','all_rows');
    completed_job_ids=saved.completed_job_ids;all_rows=saved.all_rows;
end
remaining=jobs(~ismember(jobs.job_id,completed_job_ids),:);
pool=gcp('nocreate');if isempty(pool),pool=parpool('Processes',4);end %#ok<NASGU>
for first=1:cfg.checkpoint_interval:height(remaining)
    last=min(first+cfg.checkpoint_interval-1,height(remaining));
    current=remaining(first:last,:);payloads=cell(height(current),1);
    parfor i=1:height(current)
        payloads{i}=recon_ensemble_worker_job(current(i,:),sample);
    end
    for i=1:numel(payloads)
        all_rows=[all_rows;payloads{i}.rows]; %#ok<AGROW>
        completed_job_ids(end+1,1)=current.job_id(i); %#ok<AGROW>
    end
    save(checkpoint_file,'completed_job_ids','all_rows','jobs','-v7.3');
    writetable(all_rows,csv_file);
    fprintf('STAGE1_PROGRESS groups=%d/%d trajectories=%d failures=%d\n', ...
        numel(completed_job_ids),height(jobs),height(all_rows), ...
        sum(~all_rows.solver_success));
end
pass=height(all_rows)==height(jobs)*3 && all(all_rows.solver_success);
fid=fopen(fullfile(cfg.dirs.verification,'stage1_gain_report.md'),'w');
fprintf(fid,'# Stage 1 Nominal Gain Sweep\n\n- Trajectories: %d\n',height(all_rows));
fprintf(fid,'- Result: **%s**\n',local_word(pass));fclose(fid);
pool=gcp('nocreate');if ~isempty(pool),delete(pool);end
if ~pass,error('ReconStudy:GainSweepFailed','Stage 1 failed QC.');end
fprintf('STAGE1_RESULT=PASS trajectories=%d\n',height(all_rows));
end

function word=local_word(value)
if value,word='PASS';else,word='FAIL';end
end

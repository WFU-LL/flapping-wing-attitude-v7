function run_pilot_smoke_test()
% Exercise one matched group before launching the long N=20 campaign.

cfg = init_recon_robustness_config();
samples = readtable(cfg.sample_file);
jobs = make_recon_robustness_jobs(cfg,1);
job = jobs(strcmp(jobs.stage,'stage6') & strcmp(jobs.scenario_id,'moderate') ...
    & strcmp(jobs.mechanism_case,'inertia-flex-wake'),:);
payload = recon_robustness_worker_job(job(1,:),samples(1,:));
writetable(payload.rows,fullfile(cfg.dirs.verification,'pilot_smoke_rows.csv'));
pass = payload.ok && height(payload.rows)==3 && all(payload.rows.solver_success) ...
    && all(isfinite(payload.rows.rmse_norm_deg));
fid=fopen(fullfile(cfg.dirs.verification,'pilot_smoke_report.md'),'w');
fprintf(fid,'# Pilot Smoke Test\n\n- Direct Simulink runs: 3\n');
fprintf(fid,'- Reconstruction case: moderate, inertia-flex-wake, C1.\n');
fprintf(fid,'- Result: **%s**\n',local_word(pass));
fclose(fid);
if bdIsLoaded(cfg.model),set_param(cfg.model,'FastRestart','off');close_system(cfg.model,0);end
if ~pass,error('ReconStudy:SmokeFailed','Pilot smoke test failed.');end
fprintf('PILOT_SMOKE_RESULT=PASS rows=3\n');
end

function word=local_word(value)
if value,word='PASS';else,word='FAIL';end
end

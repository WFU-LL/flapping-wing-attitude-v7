function payload=recon_ensemble_worker_job(job,samples)
% Run one three-condition direct-Simulink ensemble group.

persistent cfg cache_ready
if isempty(cfg),cfg=init_recon_robustness_config();end
if isempty(cache_ready)
    task=getCurrentTask();
    if isempty(task),tag='client';else,tag=sprintf('worker_%d',task.ID);end
    sfe_prepare_worker_cache(cfg,['recon_ensemble_' tag]);
    cache_ready=true;
end
payload=struct('ok',false,'error_message','','rows',table(), ...
    'batch_runtimes',nan(1,3));
timer=tic;
try
    [runs,~,batch_runtimes]=run_recon_ensemble_group(cfg,samples,job);
    rows=table();
    for si=1:height(samples)
        nominal=runs{1}(si);
        rows=[rows;recon_result_to_schema_row(job,samples(si,:), ...
            nominal,[])]; %#ok<AGROW>
        rows=[rows;recon_result_to_schema_row(job,samples(si,:), ...
            runs{2}(si),nominal)]; %#ok<AGROW>
        rows=[rows;recon_result_to_schema_row(job,samples(si,:), ...
            runs{3}(si),nominal)]; %#ok<AGROW>
    end
    payload.rows=rows;payload.ok=true;payload.batch_runtimes=batch_runtimes;
catch ME
    payload.error_message=sprintf('%s: %s',ME.identifier,ME.message);
    payload.rows=recon_failure_schema_rows(job,samples, ...
        payload.error_message,toc(timer)/max(height(samples),1));
end
end

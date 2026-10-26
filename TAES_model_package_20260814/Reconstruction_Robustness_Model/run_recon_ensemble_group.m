function [runs,noise_meta,batch_runtimes]=run_recon_ensemble_group( ...
    cfg,samples,job)
% Run N independent samples together for nominal and two disturbances.

if istable(job),job=table2struct(job);end
scenario=struct('k',job.k,'delta',job.delta,'delay_ms',job.delay_ms, ...
    'noise_rms_fraction',job.noise_rms_fraction, ...
    'filter_cutoff_hz',job.filter_cutoff_hz);
[P,noise_meta]=prepare_recon_batch_workspace(cfg,samples, ...
    job.mechanism_case,job.controller,scenario);
model='model_recon_robustness_ensemble';
model_file=fullfile(cfg.study_dir,[model '.slx']);
load_system(model_file);
if strcmp(get_param(model,'FastRestart'),'off')
    set_param(model,'SolverType','Variable-step','StopTime', ...
        num2str(cfg.stop_time,17),'Solver','ode45','MaxStep', ...
        num2str(cfg.max_step,17),'ReturnWorkspaceOutputs','on', ...
        'OutputOption','SpecifiedOutputTimes','OutputTimes', ...
        sprintf('0:%.17g:%.17g',cfg.max_step,cfg.stop_time), ...
        'SimulationMode','normal');
    set_param(model,'FastRestart','on');
end
conditions={'none','yaw_impulse','multi_axis_sine'};
runs=cell(1,3);batch_runtimes=zeros(1,3);
for i=1:3
    P.external_condition=conditions{i};
    assignin('base','recon_batch_params_v8',P);
    assignin('base','recon_batch_token_v8', ...
        v6_param('recon_batch_token_v8',0)+1);
    timer=tic;sim_out=sim(model);batch_runtimes(i)=toc(timer);
    current=extract_recon_ensemble_simout( ...
        sim_out.get('simout_recon_ensemble'),height(samples));
    for j=1:numel(current)
        current(j).external_condition=conditions{i};
        current(j).runtime_seconds=batch_runtimes(i)/height(samples);
        current(j).noise_meta=struct('seed',noise_meta.seed(j), ...
            'actual_rms',noise_meta.actual_rms(j,:));
    end
    runs{i}=current;
end
end

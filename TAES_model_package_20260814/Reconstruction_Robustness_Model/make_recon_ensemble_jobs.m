function jobs=make_recon_ensemble_jobs(cfg)
% Build Stage 2-7 scenario/controller groups; samples are batched separately.

records=struct([]);next_id=0;
for ci=1:size(cfg.cases,1)
    mechanism_case=cfg.cases{ci,1};
    controllers={'C0_baseline_PD','C1_selective','C2_all_axis'};
    for i=1:numel(controllers)
        add_job('stage2','exact_k030',controllers{i},mechanism_case,0.3,0,0,0,20);
    end
    for value=cfg.bias_sweep
        add_job('stage3',sprintf('bias_%+0.2f',value),'C1_selective', ...
            mechanism_case,0.3,value,0,0,20);
    end
    for value=cfg.delay_ms_sweep
        add_job('stage4',sprintf('delay_%02dms',value),'C1_selective', ...
            mechanism_case,0.3,0,value,0,20);
    end
    for value=cfg.noise_rms_fraction_sweep
        add_job('stage5',sprintf('noise_%0.2f',value),'C1_selective', ...
            mechanism_case,0.3,0,0,value,20);
    end
    for i=1:numel(cfg.combined_scenarios)
        s=cfg.combined_scenarios(i);
        add_job('stage6',s.name,'C1_selective',mechanism_case,0.3, ...
            s.delta,s.delay_ms,s.noise_rms_fraction,20);
    end
    moderate=cfg.combined_scenarios(strcmp( ...
        {cfg.combined_scenarios.name},'moderate'));
    add_job('stage7','moderate_unfiltered','C1_selective', ...
        mechanism_case,0.3,moderate.delta,moderate.delay_ms, ...
        moderate.noise_rms_fraction,20);
    for value=cfg.filter_cutoff_hz_sweep
        add_job('stage7',sprintf('moderate_lpf_%02dHz',value), ...
            'C3_selective_LPF',mechanism_case,0.3,moderate.delta, ...
            moderate.delay_ms,moderate.noise_rms_fraction,value);
    end
end
jobs=struct2table(records);

    function add_job(stage,scenario_id,controller,mechanism_case,k, ...
            delta,delay_ms,noise_rms_fraction,filter_cutoff_hz)
        next_id=next_id+1;
        records(next_id).job_id=next_id;
        records(next_id).stage=string(stage);
        records(next_id).scenario_id=string(scenario_id);
        records(next_id).controller=string(controller);
        records(next_id).mechanism_case=string(mechanism_case);
        records(next_id).k=k;
        records(next_id).delta=delta;
        records(next_id).delay_ms=delay_ms;
        records(next_id).noise_rms_fraction=noise_rms_fraction;
        records(next_id).filter_cutoff_hz=filter_cutoff_hz;
    end
end

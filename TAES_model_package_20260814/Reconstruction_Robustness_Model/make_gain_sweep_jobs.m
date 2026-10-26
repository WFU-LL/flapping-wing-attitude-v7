function jobs=make_gain_sweep_jobs(cfg)
% Build nominal Stage 1 C1/C2 gain-sweep groups.

records=struct([]);id=0;
for ci=1:size(cfg.cases,1)
    for controller={'C1_selective','C2_all_axis'}
        for k=cfg.gain_sweep
            id=id+1;records(id).job_id=id;
            records(id).stage="stage1";
            records(id).scenario_id=string(sprintf('gain_%0.2f',k));
            records(id).controller=string(controller{1});
            records(id).mechanism_case=string(cfg.cases{ci,1});
            records(id).k=k;records(id).delta=0;records(id).delay_ms=0;
            records(id).noise_rms_fraction=0;records(id).filter_cutoff_hz=20;
        end
    end
end
jobs=struct2table(records);
end

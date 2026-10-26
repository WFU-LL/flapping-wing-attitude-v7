function rows=recon_failure_schema_rows(job,samples,message,runtime)
% Create explicit failed rows without inventing numerical metrics.

if istable(job),job=table2struct(job);end
conditions={'none','yaw_impulse','multi_axis_sine'};
rows=table();
for si=1:height(samples)
    for ci=1:3
        gain=local_gain(job.controller,job.k);delta=repmat(job.delta,1,3);
        prefix={string(job.stage),string(job.scenario_id),string(job.controller), ...
            string(job.mechanism_case),string(conditions{ci}),samples.sample_id(si), ...
            gain(1),gain(2),gain(3),delta(1),delta(2),delta(3),job.delay_ms, ...
            job.noise_rms_fraction,20260712+samples.sample_id(si)};
        values=[prefix,num2cell(nan(1,24)),{false,string(message),runtime}];
        rows=[rows;cell2table(values,'VariableNames', ...
            recon_run_schema_names())]; %#ok<AGROW>
    end
end
end

function gain=local_gain(controller,k)
switch char(controller)
    case 'C0_baseline_PD',gain=[0 0 0];
    case {'C1_selective','C3_selective_LPF'},gain=[k 0 k];
    case 'C2_all_axis',gain=[k k k];
end
end

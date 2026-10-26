function result = run_recon_robustness_case(cfg, sample, mechanism_case, ...
    external_condition, controller, scenario)
% Run one direct Simulink trajectory with explicit reconstruction settings.

if istable(sample), sample = table2struct(sample); end
overrides = v8_sample_overrides(sample);
names = fieldnames(overrides);
for i = 1:numel(names), assignin('base', names{i}, overrides.(names{i})); end

case_idx = find(strcmp(cfg.cases(:,1), mechanism_case), 1);
if isempty(case_idx), error('ReconStudy:UnknownCase', mechanism_case); end
assignin('base', 'enable_inertia_v8', cfg.cases{case_idx,2});
assignin('base', 'enable_flex_v8', cfg.cases{case_idx,3});
assignin('base', 'enable_wake_v8', cfg.cases{case_idx,4});
assignin('base', 'disturbance_case_v8', external_condition);

gain = scenario.k;
switch char(controller)
    case 'C0_baseline_PD'
        gain_vector = [0;0;0];
        use_filter = false;
    case 'C1_selective'
        gain_vector = [gain;0;gain];
        use_filter = false;
    case 'C2_all_axis'
        gain_vector = [gain;gain;gain];
        use_filter = false;
    case 'C3_selective_LPF'
        gain_vector = [gain;0;gain];
        use_filter = true;
    otherwise
        error('ReconStudy:UnknownController', 'Unknown controller: %s', controller);
end

delta = scenario.delta;
if isscalar(delta), delta = repmat(delta,3,1); end
assignin('base', 'recon_gain_vector_v8', gain_vector);
assignin('base', 'recon_delta_v8', delta(:));
assignin('base', 'recon_delay_ms_v8', scenario.delay_ms);
assignin('base', 'recon_use_filter_v8', use_filter);
assignin('base', 'recon_filter_cutoff_hz_v8', scenario.filter_cutoff_hz);
assignin('base', 'Mcomp_limit_v8', 0.15);
noise_meta = prepare_recon_noise_v8(cfg, sample.sample_id, ...
    mechanism_case, scenario.noise_rms_fraction);

load_system(cfg.model_file);
if strcmp(get_param(cfg.model,'FastRestart'),'off')
    set_param(cfg.model, 'SolverType', 'Variable-step', ...
        'StopTime', num2str(cfg.stop_time,17), 'Solver', 'ode45', ...
        'MaxStep', num2str(cfg.max_step,17), 'ReturnWorkspaceOutputs', 'on', ...
        'OutputOption', 'SpecifiedOutputTimes', ...
        'OutputTimes', sprintf('0:%.17g:%.17g', cfg.max_step, cfg.stop_time), ...
        'SimulationMode', 'normal');
end

timer_value = tic;
sim_out = sim(cfg.model);
runtime_seconds = toc(timer_value);
data = extract_recon_robustness_simout( ...
    sim_out.get('simout_recon_robustness'));

result = data;
result.sample_id = sample.sample_id;
result.mechanism_case = mechanism_case;
result.external_condition = external_condition;
result.controller = controller;
result.scenario = scenario;
result.noise_meta = noise_meta;
result.runtime_seconds = runtime_seconds;
result.source = ['Direct Simulink run: sim(' cfg.model ')'];
end

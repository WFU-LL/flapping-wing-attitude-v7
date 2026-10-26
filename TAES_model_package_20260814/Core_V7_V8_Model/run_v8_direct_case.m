function result = run_v8_direct_case(cfg, case_name, controller_mode, disturbance_case, overrides)
% Run one direct V8 Simulink case with explicit provenance.

if nargin < 5
    overrides = struct();
end
case_idx = find(strcmp(cfg.cases(:, 1), case_name), 1);
controller_idx = find(strcmp(cfg.controller_modes(:, 1), controller_mode), 1);
if isempty(case_idx) || isempty(controller_idx)
    error('V8:UnknownConfiguration', 'Unknown case or controller mode.');
end

names = fieldnames(overrides);
for i = 1:numel(names)
    assignin('base', names{i}, overrides.(names{i}));
end
assignin('base', 'enable_inertia_v8', cfg.cases{case_idx, 2});
assignin('base', 'enable_flex_v8', cfg.cases{case_idx, 3});
assignin('base', 'enable_wake_v8', cfg.cases{case_idx, 4});
assignin('base', 'enable_compensation_v8', cfg.controller_modes{controller_idx, 2});
assignin('base', 'disturbance_case_v8', disturbance_case);
if ~isfield(overrides, 'x0_v8')
    assignin('base', 'x0_v8', evalin('base', 'x0_v8'));
end

load_system(cfg.model_v8);
if strcmp(get_param(cfg.model_v8, 'FastRestart'), 'off')
    set_param(cfg.model_v8, 'SolverType', 'Variable-step', ...
        'StopTime', num2str(cfg.stop_time, 17), ...
        'Solver', 'ode45', 'MaxStep', num2str(cfg.max_step, 17), ...
        'ReturnWorkspaceOutputs', 'on', 'OutputOption', 'SpecifiedOutputTimes', ...
        'OutputTimes', sprintf('0:%.17g:%.17g', cfg.max_step, cfg.stop_time), ...
        'SimulationMode', 'normal');
end

timer_value = tic;
sim_out = sim(cfg.model_v8);
runtime_sec = toc(timer_value);
data = extract_v8_simout(sim_out.get('simout_v8'));

result = data;
result.case_name = case_name;
result.controller_mode = controller_mode;
result.disturbance_case = disturbance_case;
result.runtime_sec = runtime_sec;
result.source = ['Direct Simulink run: sim(' cfg.model_v8 ')'];
end

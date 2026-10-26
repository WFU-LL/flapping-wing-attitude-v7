% Build the separately versioned V8 coupling-aware compensation model.

clear;
clc;
run('init_flapping_wing_v8_params.m');

if bdIsLoaded(model_v8)
    close_system(model_v8, 0);
end
if exist([model_v8 '.slx'], 'file')
    error('V8:ModelExists', ['Refusing to overwrite existing V8 model. ', ...
        'Rename or archive it explicitly before rebuilding.']);
end

new_system(model_v8);
set_param(model_v8, 'StopTime', num2str(sim_stop_time_v8));
set_param(model_v8, 'Solver', 'ode45');
set_param(model_v8, 'MaxStep', num2str(sim_max_step_v8));
set_param(model_v8, 'ReturnWorkspaceOutputs', 'on');

try
    add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function', ...
        [model_v8 '/CouplingAwareAttitudePlantV8'], ...
        'Position', [190 120 440 220]);
catch
    add_block('simulink/User-Defined Functions/S-Function', ...
        [model_v8 '/CouplingAwareAttitudePlantV8'], ...
        'Position', [190 120 440 220]);
end
set_param([model_v8 '/CouplingAwareAttitudePlantV8'], ...
    'FunctionName', 'flapping_wing_attitude_sfun_v8');

add_block('simulink/Sinks/To Workspace', [model_v8 '/simout_v8'], ...
    'Position', [540 150 670 185], 'VariableName', 'simout_v8', ...
    'SaveFormat', 'Timeseries');
add_line(model_v8, 'CouplingAwareAttitudePlantV8/1', 'simout_v8/1', ...
    'autorouting', 'on');

set_param(model_v8, 'Description', sprintf(['V8 separately versioned model.\n', ...
    'V7 dynamics and parameters are preserved.\n', ...
    'Added: algebraic model-assisted M_IFA estimate and bounded compensation path.']));
save_system(model_v8);
close_system(model_v8, 0);
disp(['Created V8 model: ' model_v8 '.slx']);

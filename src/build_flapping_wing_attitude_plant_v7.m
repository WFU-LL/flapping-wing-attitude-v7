% build_flapping_wing_attitude_plant_v7.m
% Build a runnable Simulink Plant with six continuous attitude states.

clear;
clc;

run('init_flapping_wing_v7_params.m');

if bdIsLoaded(model_v7)
    close_system(model_v7, 0);
end
if exist([model_v7 '.slx'], 'file')
    delete([model_v7 '.slx']);
end

new_system(model_v7);
set_param(model_v7, 'StopTime', num2str(sim_stop_time_v7));
set_param(model_v7, 'Solver', 'ode45');
set_param(model_v7, 'MaxStep', num2str(sim_max_step_v7));
set_param(model_v7, 'ReturnWorkspaceOutputs', 'on');

try
    add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function', ...
        [model_v7 '/SixStateFlappingWingPlantV7'], ...
        'Position', [190 120 420 220]);
catch
    add_block('simulink/User-Defined Functions/S-Function', ...
        [model_v7 '/SixStateFlappingWingPlantV7'], ...
        'Position', [190 120 420 220]);
end
set_param([model_v7 '/SixStateFlappingWingPlantV7'], ...
    'FunctionName', 'flapping_wing_attitude_sfun_v7');

add_block('simulink/Sinks/To Workspace', [model_v7 '/simout_v7'], ...
    'Position', [520 150 650 185], ...
    'VariableName', 'simout_v7', ...
    'SaveFormat', 'Timeseries');

try
    add_line(model_v7, 'SixStateFlappingWingPlantV7/1', 'simout_v7/1', 'autorouting', 'on');
catch ME
    if isempty(strfind(ME.message, 'already'))
        rethrow(ME);
    end
end

save_system(model_v7);
close_system(model_v7, 0);
disp(['Created runnable Simulink model: ' model_v7 '.slx']);

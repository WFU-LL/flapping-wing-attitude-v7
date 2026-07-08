%% init_flapping_wing_v7_params.m
% V7 inherits V6 parameters and adds Simulink-specific settings.

run('init_flapping_wing_v6_params.m');

%% V7 model and simulation settings
model_v7 = 'flapping_wing_attitude_plant_v7';
result_dir_v7 = 'simulation_results_v7';

if ~exist(result_dir_v7, 'dir')
    mkdir(result_dir_v7);
end

%% Case switches
enable_inertia_v7 = 0;
enable_flex_v7 = 0;
enable_wake_v7 = 0;

%% Initial state vector
x0_v7 = [roll0; pitch0; yaw0; p0; q0; r0];

%% Solver settings
sim_stop_time_v7 = t_final_v6;
sim_max_step_v7 = 0.001;

%% Acceptance threshold for ODE-Simulink equivalence
accept_max_att_diff_deg_v7 = 0.05;
accept_max_rate_diff_v7 = 1e-3;

%% Sensitivity scales
scale_grid_v7 = [0.025 0.05 0.075 0.10];
wake_scale_grid_v7 = [0 0.025 0.05 0.075 0.10];

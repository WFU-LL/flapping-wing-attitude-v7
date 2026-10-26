%% init_flapping_wing_v8_params.m
% V8 adds a separately versioned coupling-aware compensation path to V7.

run('init_flapping_wing_v7_params.m');

model_v8 = 'flapping_wing_attitude_plant_v8_compensation';
result_dir_v8 = 'simulation_results_v8_compensation';
if ~exist(result_dir_v8, 'dir')
    mkdir(result_dir_v8);
end

enable_inertia_v8 = 0;
enable_flex_v8 = 0;
enable_wake_v8 = 0;
enable_compensation_v8 = 0;
disturbance_case_v8 = 'none';
x0_v8 = x0_v7;

% Algebraic model-assisted coupled-moment estimate and compensation settings.
coupled_moment_estimator_mode_v8 = 'algebraic_model_assisted';
Kcomp_mifa_v8 = [0.30; 0.00; 0.30]; % selective roll/pitch/yaw compensation
Mcomp_limit_v8 = 0.15;               % N*m, component-wise compensation limit

% External disturbance settings are independent of the IFA estimator.
disturbance_moment_amp_v8 = 0.05;     % N*m
disturbance_time_v8 = 1.0;            % s
disturbance_duration_v8 = 0.10;       % s

sim_stop_time_v8 = sim_stop_time_v7;
sim_max_step_v8 = sim_max_step_v7;

v8_attitude_equivalence_tol_deg = 1e-6;
v8_rate_equivalence_tol = 1e-8;
v8_moment_equivalence_tol = 1e-8;

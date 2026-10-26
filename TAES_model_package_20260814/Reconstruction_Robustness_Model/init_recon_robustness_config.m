function cfg = init_recon_robustness_config()
% Configuration for the isolated V8 reconstruction robustness study.

study_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(study_dir);
addpath(project_root, study_dir);

init_file = fullfile(project_root, 'init_flapping_wing_v8_params.m');
evalin('base', sprintf('KEEP_WORKSPACE_FLAG = true; run(''%s'');', ...
    strrep(init_file, '''', '''''')));

cfg = struct();
cfg.study_dir = study_dir;
cfg.project_root = project_root;
cfg.model = 'model_recon_robustness';
cfg.model_file = fullfile(study_dir, [cfg.model '.slx']);
cfg.source_model = 'flapping_wing_attitude_plant_v8_compensation';
cfg.stop_time = evalin('base', 'sim_stop_time_v8');
cfg.max_step = 0.005;
cfg.output_times = (0:cfg.max_step:cfg.stop_time).';
cfg.seed = 20260712;
cfg.pilot_n = 20;
cfg.full_n = 100;
cfg.checkpoint_interval = 10;
cfg.bootstrap_resamples = 2000;
cfg.cases = {
    'inertia-flex', 1, 1, 0;
    'inertia-flex-wake', 1, 1, 1
    };
cfg.external_conditions = {'none','yaw_impulse','multi_axis_sine'};
cfg.matched_external_conditions = {'yaw_impulse','multi_axis_sine'};
cfg.gain_sweep = 0:0.1:0.6;
cfg.bias_sweep = -0.3:0.1:0.3;
cfg.delay_ms_sweep = [0 5 10 20 40];
cfg.noise_rms_fraction_sweep = [0 0.01 0.03 0.05];
cfg.filter_cutoff_hz_sweep = [5 10 20 40];
cfg.noise_generation_hz = 1000;
cfg.noise_bandlimit_hz = 20;
cfg.combined_scenarios = struct( ...
    'name', {'mild','moderate','severe','delay_dominant'}, ...
    'delta', {0.1,0.2,0.3,0.2}, ...
    'delay_ms', {5,10,20,40}, ...
    'noise_rms_fraction', {0.01,0.03,0.05,0.05});
cfg.acceptance = struct('improved_fraction_min', 0.90, ...
    'energy_ratio_p95_max', 1.50, 'median_reduction_min', 0, ...
    'max_attitude_deg', 60);

cfg.output_dir = fullfile(study_dir, 'output');
subdirs = {'verification','checkpoints','raw','logs','figures','tables','reports'};
for i = 1:numel(subdirs)
    path_i = fullfile(cfg.output_dir, subdirs{i});
    if ~exist(path_i, 'dir'), mkdir(path_i); end
    cfg.dirs.(subdirs{i}) = path_i;
end

sample_candidates = {
    fullfile(project_root, 'paper_revision_nd', 'targeted_analysis', ...
        'v8_control_N100', 'V8_paired_N100_samples.csv');
    fullfile(project_root, 'ND_Phase8_Canonical_Research_Archive', ...
        '04_Raw_Simulation_Data', 'V8_N100', 'V8_paired_N100_samples.csv')
    };
cfg.sample_file = '';
for i = 1:numel(sample_candidates)
    if exist(sample_candidates{i}, 'file')
        cfg.sample_file = sample_candidates{i};
        break;
    end
end
if isempty(cfg.sample_file)
    error('ReconStudy:MissingSamples', ...
        'The protected V8 N=100 matched sample table was not found.');
end

nominal_names = {'Jx','Jy','Jz','Dx','Dy','Dz','scale_inertia_v6', ...
    'scale_flex_v6','scale_wake_v6','f_flap','A0'};
for i = 1:numel(nominal_names)
    cfg.nominal.(nominal_names{i}) = evalin('base', nominal_names{i});
end

local_assign_default('recon_delta_v8', zeros(3,1));
local_assign_default('recon_delay_ms_v8', 0);
local_assign_default('recon_noise_values_v8', zeros(1,3));
local_assign_default('recon_noise_fs_v8', cfg.noise_generation_hz);
local_assign_default('recon_use_filter_v8', false);
local_assign_default('recon_filter_cutoff_hz_v8', 20);
local_assign_default('recon_gain_vector_v8', [0.3;0;0.3]);
end

function local_assign_default(name, value)
assignin('base', name, value);
end

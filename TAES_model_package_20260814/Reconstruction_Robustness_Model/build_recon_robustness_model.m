function build_recon_robustness_model()
% Repoint only the copied model's S-function and logging variable.

cfg = init_recon_robustness_config();
source_file = fullfile(cfg.project_root, [cfg.source_model '.slx']);
if ~exist(cfg.model_file, 'file')
    copyfile(source_file, cfg.model_file);
end

load_system(cfg.model_file);
plant_block = [cfg.model '/CouplingAwareAttitudePlantV8'];
workspace_block = [cfg.model '/simout_v8'];
set_param(plant_block, 'FunctionName', ...
    'flapping_wing_attitude_sfun_recon_robustness');
set_param(workspace_block, 'VariableName', 'simout_recon_robustness');
save_system(cfg.model, cfg.model_file);
close_system(cfg.model, 0);

fprintf('RECON_MODEL_BUILT=%s\n', cfg.model_file);
end

function build_recon_robustness_ensemble_model()
% Build a copied model that batches independent matched samples per sim call.

cfg = init_recon_robustness_config();
ensemble_model = 'model_recon_robustness_ensemble';
ensemble_file = fullfile(cfg.study_dir,[ensemble_model '.slx']);
copyfile(fullfile(cfg.project_root,[cfg.source_model '.slx']),ensemble_file);
load_system(ensemble_file);
set_param([ensemble_model '/CouplingAwareAttitudePlantV8'], ...
    'FunctionName','flapping_wing_attitude_sfun_recon_ensemble');
set_param([ensemble_model '/simout_v8'],'VariableName', ...
    'simout_recon_ensemble');
save_system(ensemble_model,ensemble_file);
close_system(ensemble_model,0);
fprintf('RECON_ENSEMBLE_MODEL_BUILT=%s\n',ensemble_file);
end

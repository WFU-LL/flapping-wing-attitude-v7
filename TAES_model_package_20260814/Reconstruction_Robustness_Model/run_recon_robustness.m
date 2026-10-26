function run_recon_robustness()
% Run or resume the complete reconstruction-robustness evidence workflow.

study_root = fileparts(mfilename('fullpath'));
old_folder = pwd;
cleanup = onCleanup(@()cd(old_folder));
cd(study_root);

fprintf('RECON_ROBUSTNESS: Stage 0 protected-model regression\n');
run_stage0_regression();

fprintf('RECON_ROBUSTNESS: direct-Simulink smoke test\n');
run_pilot_smoke_test();

fprintf('RECON_ROBUSTNESS: ensemble-versus-single equivalence\n');
run_ensemble_equivalence_check();

fprintf('RECON_ROBUSTNESS: Stage 1 gain sweep (checkpoint-aware)\n');
run_gain_sweep_stage1();

fprintf('RECON_ROBUSTNESS: N=20 pilot (checkpoint-aware)\n');
run_reconstruction_pilot();

fprintf('RECON_ROBUSTNESS: N=100 campaign (checkpoint-aware)\n');
run_reconstruction_full_N100();

fprintf('RECON_ROBUSTNESS: analysis and publication outputs\n');
analyze_recon_robustness();
fprintf('RECON_ROBUSTNESS_RESULT=PASS\n');
clear cleanup
end

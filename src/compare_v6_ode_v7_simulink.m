function passed = compare_v6_ode_v7_simulink
% Compare V6 ode45 script results against V7 Simulink results.

run('init_flapping_wing_v7_params.m');

cases = {'rigid_baseline','inertia_only','inertia_flex','inertia_flex_wake'};
max_att_diff_all = 0;
max_rate_diff_all = 0;
rmse_diff_all = 0;

fid = fopen(fullfile(result_dir_v7, 'v6_v7_equivalence_report.txt'), 'w');
fprintf(fid, 'V6 ode45 vs V7 Simulink equivalence report\n');
fprintf(fid, 'Generated at: %s\n\n', datestr(now));

for i = 1:length(cases)
    case_name = cases{i};
    v6 = load(fullfile('simulation_results_v6', ['result_v6_' case_name '.mat']));
    v7 = load(fullfile(result_dir_v7, ['result_v7_' case_name '.mat']));

    x7_on_v6 = interp1(v7.t, v7.x, v6.t, 'linear', 'extrap');
    att_diff_deg = (v6.x(:, 1:3) - x7_on_v6(:, 1:3)) * 180/pi;
    rate_diff = v6.x(:, 4:6) - x7_on_v6(:, 4:6);

    max_att_diff = max(max(abs(att_diff_deg)));
    max_rate_diff = max(max(abs(rate_diff)));
    rmse_diff = sqrt(mean(att_diff_deg(:).^2));

    max_att_diff_all = max(max_att_diff_all, max_att_diff);
    max_rate_diff_all = max(max_rate_diff_all, max_rate_diff);
    rmse_diff_all = max(rmse_diff_all, rmse_diff);

    fprintf(fid, 'Case: %s\n', case_name);
    fprintf(fid, '  max attitude difference deg = %.16g\n', max_att_diff);
    fprintf(fid, '  max rate difference = %.16g\n', max_rate_diff);
    fprintf(fid, '  attitude RMSE difference deg = %.16g\n\n', rmse_diff);
end

fprintf(fid, 'Overall max attitude difference deg = %.16g\n', max_att_diff_all);
fprintf(fid, 'Overall max rate difference = %.16g\n', max_rate_diff_all);
fprintf(fid, 'Overall max attitude RMSE difference deg = %.16g\n', rmse_diff_all);
fprintf(fid, 'Acceptance: max attitude <= %.16g deg, max rate <= %.16g\n', ...
    accept_max_att_diff_deg_v7, accept_max_rate_diff_v7);

passed = max_att_diff_all <= accept_max_att_diff_deg_v7 && max_rate_diff_all <= accept_max_rate_diff_v7;
if passed
    fprintf(fid, 'PASS: V7 Simulink reproduces V6 ode45 within tolerance.\n');
else
    fprintf(fid, 'FAIL: V7 Simulink does not reproduce V6 ode45 within tolerance. Do not use final V7 plots.\n');
end
fclose(fid);
end

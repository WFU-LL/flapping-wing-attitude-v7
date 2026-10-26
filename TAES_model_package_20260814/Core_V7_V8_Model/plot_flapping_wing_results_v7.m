function plot_flapping_wing_results_v7
% Generate V7 publication-style result figures.

run('init_flapping_wing_v7_params.m');

cases = {'rigid_baseline','inertia_only','inertia_flex','inertia_flex_wake'};
labels = {'Rigid baseline','Inertia only','Inertia + flex','Inertia + flex + wake'};
colors = lines(length(cases));

figure('Name', 'V7 attitude comparison', 'Color', 'w');
for i = 1:length(cases)
    data = load(fullfile(result_dir_v7, ['result_v7_' cases{i} '.mat']));
    att_deg = data.x(:, 1:3) * 180/pi;
    subplot(3, 1, 1); hold on; grid on;
    plot(data.t, att_deg(:, 1), 'Color', colors(i, :), 'LineWidth', 1.1);
    ylabel('roll phi (deg)');
    subplot(3, 1, 2); hold on; grid on;
    plot(data.t, att_deg(:, 2), 'Color', colors(i, :), 'LineWidth', 1.1);
    ylabel('pitch theta (deg)');
    subplot(3, 1, 3); hold on; grid on;
    plot(data.t, att_deg(:, 3), 'Color', colors(i, :), 'LineWidth', 1.1);
    ylabel('yaw psi (deg)');
    xlabel('time (s)');
end
subplot(3, 1, 1); legend(labels, 'Location', 'best');
sgtitle('V7 simplified flapping-wing attitude Plant');
saveas(gcf, fullfile(result_dir_v7, 'attitude_comparison_v7.png'));
saveas(gcf, fullfile(result_dir_v7, 'attitude_comparison_v7.fig'));

figure('Name', 'V7 flexible moment terms', 'Color', 'w');
for i = 1:length(cases)
    data = load(fullfile(result_dir_v7, ['result_v7_' cases{i} '.mat']));
    F = data.F_terms;
    subplot(3, 1, 1); hold on; grid on;
    plot(data.t, F(:, 7), 'Color', colors(i, :), 'LineWidth', 1.1);
    ylabel('Mx flex (N m)');
    subplot(3, 1, 2); hold on; grid on;
    plot(data.t, F(:, 8), 'Color', colors(i, :), 'LineWidth', 1.1);
    ylabel('My flex (N m)');
    subplot(3, 1, 3); hold on; grid on;
    plot(data.t, F(:, 9), 'Color', colors(i, :), 'LineWidth', 1.1);
    ylabel('Mz flex (N m)');
    xlabel('time (s)');
end
subplot(3, 1, 1); legend(labels, 'Location', 'best');
sgtitle('V7 flexible moment terms');
saveas(gcf, fullfile(result_dir_v7, 'flexible_moment_terms_v7.png'));
saveas(gcf, fullfile(result_dir_v7, 'flexible_moment_terms_v7.fig'));

m = load(fullfile(result_dir_v7, 'metrics_v7.mat'));
metrics = m.metrics;
rmse = zeros(length(metrics), 3);
final_att = zeros(length(metrics), 3);
for i = 1:length(metrics)
    rmse(i, :) = metrics(i).rmse_att_deg;
    final_att(i, :) = metrics(i).final_att_deg;
end

figure('Name', 'V7 ablation RMSE', 'Color', 'w');
bar(rmse);
grid on;
set(gca, 'XTickLabel', labels, 'XTickLabelRotation', 20);
ylabel('attitude RMSE (deg)');
legend({'roll','pitch','yaw'}, 'Location', 'best');
title('V7 ablation attitude RMSE');
saveas(gcf, fullfile(result_dir_v7, 'ablation_rmse_bar_v7.png'));
saveas(gcf, fullfile(result_dir_v7, 'ablation_rmse_bar_v7.fig'));

figure('Name', 'V7 final attitude', 'Color', 'w');
bar(final_att);
grid on;
set(gca, 'XTickLabel', labels, 'XTickLabelRotation', 20);
ylabel('final attitude (deg)');
legend({'roll','pitch','yaw'}, 'Location', 'best');
title('V7 final attitude by ablation case');
saveas(gcf, fullfile(result_dir_v7, 'final_attitude_bar_v7.png'));
saveas(gcf, fullfile(result_dir_v7, 'final_attitude_bar_v7.fig'));
end

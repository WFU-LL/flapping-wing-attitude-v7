function m = compute_v8_control_metrics(disturbed, nominal, cfg)
% Compute tracking, disturbance-recovery, effort and saturation metrics.

t = disturbed.t(:);
att_deg = rad2deg(disturbed.x(:, 1:3));
rates = disturbed.x(:, 4:6);
reference_deg = rad2deg([v6_param('roll_ref', 0), ...
    v6_param('pitch_ref', 0), v6_param('yaw_ref', 0)]);
error_deg = att_deg - reference_deg;
axis_rmse = sqrt(mean(error_deg.^2, 1));

m.tracking_rmse_norm_deg = norm(axis_rmse);
m.max_attitude_deg = max(abs(att_deg), [], 'all');
m.final_residual_deg = norm(error_deg(end, :));
m.rate_energy = trapz(t, sum(rates.^2, 2));
m.control_energy = trapz(t, sum(disturbed.M_c.^2, 2));
m.compensation_energy = trapz(t, sum(disturbed.M_comp.^2, 2));
m.saturation_fraction = mean(any(disturbed.saturation_flag > 0.5, 2));
m.estimator_rmse_Nm = sqrt(mean((disturbed.M_ifa - disturbed.M_ifa_hat).^2, 'all'));

if isempty(nominal)
    m.peak_disturbance_deviation_deg = NaN;
    m.post_disturbance_iae_deg_s = NaN;
    m.recovery_time_s = NaN;
    m.final_disturbance_residual_deg = NaN;
    return;
end

nominal_att = interp1(nominal.t, rad2deg(nominal.x(:, 1:3)), t, 'linear');
delta_norm = vecnorm(att_deg - nominal_att, 2, 2);
t0 = v6_param('disturbance_time_v8', 1.0);
duration = v6_param('disturbance_duration_v8', 0.1);
post = t >= t0;
m.peak_disturbance_deviation_deg = max(delta_norm(post));
m.post_disturbance_iae_deg_s = trapz(t(post), delta_norm(post));
m.final_disturbance_residual_deg = delta_norm(end);

if strcmp(disturbed.disturbance_case, 'multi_axis_sine')
    m.recovery_time_s = NaN;
else
    end_time = t0 + duration;
    threshold = max(0.05, 0.02 * m.peak_disturbance_deviation_deg);
    after = find(t >= end_time);
    last_outside = find(delta_norm(after) > threshold, 1, 'last');
    if isempty(last_outside)
        m.recovery_time_s = 0;
    elseif after(last_outside) == numel(t)
        m.recovery_time_s = NaN;
    else
        m.recovery_time_s = t(after(last_outside)) - end_time;
    end
end

if nargin > 2 && isfield(cfg, 'acceptance')
    m.bounded_flag = double(m.max_attitude_deg <= 60);
end
end


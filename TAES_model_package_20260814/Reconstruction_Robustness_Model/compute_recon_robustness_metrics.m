function m = compute_recon_robustness_metrics(result, nominal)
% Compute the run-level metrics required by the task schema.

t = result.t(:);
x = result.x;
att_deg = rad2deg(x(:,1:3));
reference_deg = rad2deg([v6_param('roll_ref',0), ...
    v6_param('pitch_ref',0), v6_param('yaw_ref',0)]);
error_deg = att_deg - reference_deg;
axis_rmse = sqrt(mean(error_deg.^2,1));

m.rmse_roll_deg = axis_rmse(1);
m.rmse_pitch_deg = axis_rmse(2);
m.rmse_yaw_deg = axis_rmse(3);
m.rmse_norm_deg = norm(axis_rmse);
m.final_roll_deg = att_deg(end,1);
m.final_pitch_deg = att_deg(end,2);
m.final_yaw_deg = att_deg(end,3);
m.max_attitude_deg = max(abs(att_deg),[],'all');
steady = t >= t(end)-1;
m.pitch_ripple_deg = max(att_deg(steady,2)) - min(att_deg(steady,2));
m.rate_energy = trapz(t,sum(x(:,4:6).^2,2));
m.control_energy_total = trapz(t,sum(result.M_c.^2,2));
m.control_energy_roll = trapz(t,result.M_c(:,1).^2);
m.control_energy_pitch = trapz(t,result.M_c(:,2).^2);
m.control_energy_yaw = trapz(t,result.M_c(:,3).^2);
m.compensation_energy = trapz(t,sum(result.M_comp.^2,2));

if nargin < 2 || isempty(nominal)
    m.disturbance_increment_iae = NaN;
else
    nominal_att = interp1(nominal.t, rad2deg(nominal.x(:,1:3)), ...
        t, 'linear');
    delta = vecnorm(att_deg-nominal_att,2,2);
    post = t >= v6_param('disturbance_time_v8',1.0);
    m.disturbance_increment_iae = trapz(t(post),delta(post));
end

baseline_raw = [-0.8*x(:,1)-0.25*x(:,4), ...
    -0.8*x(:,2)-0.25*x(:,5), -0.6*x(:,3)-0.20*x(:,6)];
terms = result.force_terms;
ifa_raw = [0.20*0.10*terms(:,3), ...
    terms(:,2)+0.15*(terms(:,3)+0.20*terms(:,5)), ...
    0.10*(terms(:,4)+terms(:,6))];
outer_raw = result.M_0 + result.M_comp;
m.ifa_saturation_fraction = mean(any(abs(ifa_raw)>0.5*(1+1e-12),2));
m.baseline_command_saturation_fraction = ...
    mean(any(abs(baseline_raw)>1.5*(1+1e-12),2));
m.compensation_saturation_fraction = ...
    mean(any(abs(result.M_comp_raw)>0.15*(1+1e-12),2));
m.outer_command_saturation_fraction = ...
    mean(any(abs(outer_raw)>1.5*(1+1e-12),2));
end

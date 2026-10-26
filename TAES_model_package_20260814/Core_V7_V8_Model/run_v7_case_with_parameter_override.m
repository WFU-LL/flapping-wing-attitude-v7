function [metrics, data] = run_v7_case_with_parameter_override(case_name, overrides)
% Fast V7-equivalent high-level wrapper for uncertainty and screening runs.
% It does not modify V7 Simulink files or V7 core dynamics.

if nargin < 2 || isempty(overrides)
    overrides = struct();
end
run('init_sci_highlevel_params.m');

p = local_params_from_workspace();
fields = fieldnames(overrides);
for i = 1:numel(fields)
    p.(fields{i}) = overrides.(fields{i});
end
if ~isfield(p, 'x0_sci')
    p.x0_sci = [roll0; pitch0; yaw0; p0; q0; r0];
end

idx = find(strcmp(case_names_hl, case_name), 1);
if isempty(idx)
    error('Unknown high-level case: %s', case_name);
end
sw = case_switch_hl(idx, :);

t = (0:dt_highlevel:t_final_v6)';
x = zeros(numel(t), 6);
x(1, :) = p.x0_sci(:)';
F_terms = zeros(numel(t), 9);
M_ctrl = zeros(numel(t), 3);

failed = false;
err_msg = '';
try
    for k = 1:numel(t)
        [dx, terms, ctrl] = local_dx(t(k), x(k, :)', sw, p);
        F_terms(k, :) = terms(:)';
        M_ctrl(k, :) = ctrl(:)';
        if k < numel(t)
            h = t(k+1) - t(k);
            k1 = dx;
            k2 = local_dx(t(k) + h/2, x(k, :)' + h*k1/2, sw, p);
            k3 = local_dx(t(k) + h/2, x(k, :)' + h*k2/2, sw, p);
            k4 = local_dx(t(k) + h, x(k, :)' + h*k3, sw, p);
            x(k+1, :) = (x(k, :)' + h*(k1 + 2*k2 + 2*k3 + k4)/6)';
        end
    end
catch ME
    failed = true;
    err_msg = ME.message;
end

data = struct();
data.t = t;
data.x = x;
data.att_deg = x(:, 1:3) * 180 / pi;
data.rates = x(:, 4:6);
data.flex_terms = F_terms;
data.M_ctrl = M_ctrl;
data.case_name = case_name;
data.failed = failed;
data.error_message = err_msg;
data.source = 'V7-equivalent high-level fast wrapper';

metrics = compute_attitude_metrics_sci(data.t, data.att_deg, data.rates, data.flex_terms, data.M_ctrl);
metrics.stable_flag = ~failed && all(isfinite(x(:))) && metrics.max_abs_att_all < divergence_angle_limit_deg_v6;
metrics.failed = failed;
metrics.error_message = err_msg;
metrics.pitch_ripple = metrics.steady_peak_to_peak(2);
metrics.yaw_ripple = metrics.steady_peak_to_peak(3);
end

function p = local_params_from_workspace()
vars = {'f_flap','A0','J_phi_wing','r_cp','dL_flex_avg_total','dL_flex_max_total', ...
    'dT_flex_max_total','dD_flex_max_total','Kwc1_total','Kwc2_total','Kwc3_total', ...
    'Kwc4_total','l_roll','l_pitch','l_yaw','M_flex_limit','scale_inertia_v6', ...
    'scale_flex_v6','scale_wake_v6','Jx','Jy','Jz','Dx','Dy','Dz', ...
    'Kp_roll','Kd_roll','Kp_pitch','Kd_pitch','Kp_yaw','Kd_yaw', ...
    'roll_ref','pitch_ref','yaw_ref','M_control_limit'};
p = struct();
for i = 1:numel(vars)
    p.(vars{i}) = evalin('caller', vars{i});
end
end

function [dx, terms, ctrl] = local_dx(t, x, sw, p)
phase = 2*pi*p.f_flap*t;
wing_phi = p.A0 * sin(phase);
wing_phi_ddot = -p.A0 * (2*pi*p.f_flap)^2 * sin(phase);

F_inertia = 0; M_inertia_pitch = 0;
if sw(1)
    M_raw_single = p.J_phi_wing * wing_phi_ddot;
    F_raw_single = M_raw_single / p.r_cp;
    F_inertia = 2 * p.scale_inertia_v6 * F_raw_single;
    M_inertia_pitch = p.scale_inertia_v6 * 2 * M_raw_single;
end

F_flex_lift = 0; F_flex_thrust = 0; F_flex_drag = 0;
if sw(2)
    F_flex_lift = p.scale_flex_v6 * (p.dL_flex_avg_total + p.dL_flex_max_total * sin(phase));
    F_flex_thrust = p.scale_flex_v6 * (0.2*p.dT_flex_max_total + p.dT_flex_max_total * sin(phase));
    F_flex_drag = p.scale_flex_v6 * (0.2*p.dD_flex_max_total + p.dD_flex_max_total * sin(phase));
end

F_wake = 0;
if sw(3)
    F_wake = p.scale_wake_v6 * (p.Kwc1_total*sin(wing_phi) + p.Kwc2_total*cos(wing_phi) + ...
        p.Kwc3_total*sin(2*wing_phi) + p.Kwc4_total*cos(2*wing_phi));
end

Mx_flex = local_sat(p.l_roll * 0.1 * F_flex_lift, p.M_flex_limit);
My_flex = local_sat(M_inertia_pitch + p.l_pitch * (F_flex_lift + 0.2*F_flex_drag), p.M_flex_limit);
Mz_flex = local_sat(p.l_yaw * (F_flex_thrust + F_wake), p.M_flex_limit);

roll = x(1); pitch = x(2); yaw = x(3); omega = x(4:6);
Mx = p.Kp_roll * (p.roll_ref - roll) - p.Kd_roll * omega(1);
My = p.Kp_pitch * (p.pitch_ref - pitch) - p.Kd_pitch * omega(2);
Mz = p.Kp_yaw * (p.yaw_ref - yaw) - p.Kd_yaw * omega(3);
ctrl = [local_sat(Mx, p.M_control_limit); local_sat(My, p.M_control_limit); local_sat(Mz, p.M_control_limit)];

p_dot = (ctrl(1) + Mx_flex - p.Dx * omega(1)) / p.Jx;
q_dot = (ctrl(2) + My_flex - p.Dy * omega(2)) / p.Jy;
r_dot = (ctrl(3) + Mz_flex - p.Dz * omega(3)) / p.Jz;
dx = [omega; p_dot; q_dot; r_dot];
terms = [F_inertia; M_inertia_pitch; F_flex_lift; F_flex_thrust; F_flex_drag; F_wake; Mx_flex; My_flex; Mz_flex];
end

function y = local_sat(x, lim)
y = min(max(x, -lim), lim);
end


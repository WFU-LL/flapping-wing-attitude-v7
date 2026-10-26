function [dz, signals] = flapping_wing_attitude_dynamics_recon_robustness(t, z)
% V8 plant with an isolated imperfect IFA reconstruction branch.

x = z(1:6);
M_hat_lpf = z(7:9);
[enable_inertia, enable_flex, enable_wake] = local_switches();

flex = flapping_wing_flexible_forces_v6(t, enable_inertia, enable_flex, enable_wake);
M_ifa = [flex.Mx_flex; flex.My_flex; flex.Mz_flex];
[M_hat_raw, M_delayed, noise_value] = recon_robustness_estimate_v8( ...
    t, enable_inertia, enable_flex, enable_wake);

fc = max(v6_param('recon_filter_cutoff_hz_v8', 20), eps);
M_hat_lpf_dot = 2*pi*fc .* (M_hat_raw - M_hat_lpf);
if logical(v6_param('recon_use_filter_v8', false))
    M_hat_used = M_hat_lpf;
else
    M_hat_used = M_hat_raw;
end

[M_c, M_0, M_comp_raw, M_comp, saturation_flag] = ...
    flapping_wing_controller_recon_robustness(x, M_hat_used);
M_dist = flapping_wing_disturbance_moment_v8(t);

omega = x(4:6);
J = [v6_param('Jx', 0.045); v6_param('Jy', 0.055); v6_param('Jz', 0.070)];
D = [v6_param('Dx', 0.08); v6_param('Dy', 0.10); v6_param('Dz', 0.12)];
omega_dot = (M_c + M_ifa + M_dist - D .* omega) ./ J;
dx = [omega; omega_dot];
dz = [dx; M_hat_lpf_dot];

if nargout > 1
    terms = [flex.F_inertia; flex.M_inertia_pitch; flex.F_flex_lift; ...
        flex.F_flex_thrust; flex.F_flex_drag; flex.F_wake; M_ifa];
    signals = struct('x', x, 'terms', terms, 'M_ifa', M_ifa, ...
        'M_delayed', M_delayed, 'noise_value', noise_value, ...
        'M_hat_raw', M_hat_raw, 'M_hat_used', M_hat_used, ...
        'M_comp_raw', M_comp_raw, 'M_0', M_0, 'M_comp', M_comp, ...
        'M_c', M_c, 'M_dist', M_dist, 'saturation_flag', saturation_flag);
end
end

function [enable_inertia, enable_flex, enable_wake] = local_switches()
enable_inertia = v6_param('enable_inertia_v8', 0);
enable_flex = v6_param('enable_flex_v8', 0);
enable_wake = v6_param('enable_wake_v8', 0);
end

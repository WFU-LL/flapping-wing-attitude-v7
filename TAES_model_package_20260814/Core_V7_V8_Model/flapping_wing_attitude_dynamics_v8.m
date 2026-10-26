function [dz, signals] = flapping_wing_attitude_dynamics_v8(t, z)
% V8 reduced-order attitude dynamics with a separate IFA compensation path.

x = z(1:6);
[enable_inertia, enable_flex, enable_wake] = local_switches();

flex = flapping_wing_flexible_forces_v6(t, enable_inertia, enable_flex, enable_wake);
M_ifa = [flex.Mx_flex; flex.My_flex; flex.Mz_flex];
comp_enabled = logical(v6_param('enable_compensation_v8', 0));
M_ifa_hat = M_ifa;

[M_c, M_0, M_comp, saturation_flag] = ...
    flapping_wing_controller_v8(x, M_ifa_hat);
M_dist = flapping_wing_disturbance_moment_v8(t);

if ~comp_enabled && all(M_dist == 0)
    dz = flapping_wing_attitude_dynamics_v7(t, x, ...
        enable_inertia, enable_flex, enable_wake);
else
    omega = x(4:6);
    J = [v6_param('Jx', 0.045); v6_param('Jy', 0.055); v6_param('Jz', 0.070)];
    D = [v6_param('Dx', 0.08); v6_param('Dy', 0.10); v6_param('Dz', 0.12)];
    omega_dot = (M_c + M_ifa + M_dist - D .* omega) ./ J;
    dz = [omega; omega_dot];
end

if nargout > 1
    terms = [flex.F_inertia; flex.M_inertia_pitch; flex.F_flex_lift; ...
        flex.F_flex_thrust; flex.F_flex_drag; flex.F_wake; M_ifa];
    signals = struct('x', x, 'terms', terms, 'M_ifa', M_ifa, ...
        'M_ifa_hat', M_ifa_hat, 'M_0', M_0, 'M_comp', M_comp, ...
        'M_c', M_c, 'M_dist', M_dist, 'saturation_flag', saturation_flag);
end
end

function [enable_inertia, enable_flex, enable_wake] = local_switches()
enable_inertia = v6_param('enable_inertia_v8', 0);
enable_flex = v6_param('enable_flex_v8', 0);
enable_wake = v6_param('enable_wake_v8', 0);
end

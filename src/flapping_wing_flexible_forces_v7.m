function y = flapping_wing_flexible_forces_v7(t, enable_inertia, enable_flex, enable_wake)
% Return vector:
% y = [F_inertia; M_inertia_pitch; F_flex_lift; F_flex_thrust; F_flex_drag; F_wake; Mx_flex; My_flex; Mz_flex]

out = flapping_wing_flexible_forces_v6(t, enable_inertia, enable_flex, enable_wake);
y = [out.F_inertia; out.M_inertia_pitch; out.F_flex_lift; ...
    out.F_flex_thrust; out.F_flex_drag; out.F_wake; ...
    out.Mx_flex; out.My_flex; out.Mz_flex];
end

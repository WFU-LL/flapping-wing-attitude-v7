function out = flapping_wing_flexible_forces_v6(t, enable_inertia, enable_flex, enable_wake)
% Generate flexible flapping-wing force and moment correction terms.

f_flap = v6_param('f_flap', 5);
A0 = v6_param('A0', pi/4);
J_phi_wing = v6_param('J_phi_wing', 0.005);
r_cp = v6_param('r_cp', 0.35);

scale_inertia_v6 = v6_param('scale_inertia_v6', 0.05);
scale_flex_v6 = v6_param('scale_flex_v6', 0.05);
scale_wake_v6 = v6_param('scale_wake_v6', 0.05);

dL_flex_avg_total = v6_param('dL_flex_avg_total', -0.446);
dL_flex_max_total = v6_param('dL_flex_max_total', -3.5);
dT_flex_max_total = v6_param('dT_flex_max_total', 15.9);
dD_flex_max_total = v6_param('dD_flex_max_total', -5.84);
Kwc1_total = v6_param('Kwc1_total', 3.18);
Kwc2_total = v6_param('Kwc2_total', 1.59);
Kwc3_total = v6_param('Kwc3_total', 1.59);
Kwc4_total = v6_param('Kwc4_total', 0.795);

l_roll = v6_param('l_roll', 0.20);
l_pitch = v6_param('l_pitch', 0.15);
l_yaw = v6_param('l_yaw', 0.10);
M_flex_limit = v6_param('M_flex_limit', 0.5);

phase = 2*pi*f_flap*t;
wing_phi = A0 * sin(phase);
wing_phi_ddot = -A0 * (2*pi*f_flap)^2 * sin(phase);

F_inertia = 0;
M_inertia_pitch = 0;
if enable_inertia
    M_raw_single = J_phi_wing * wing_phi_ddot;
    F_raw_single = M_raw_single / r_cp;
    F_inertia = 2 * scale_inertia_v6 * F_raw_single;
    M_inertia_pitch = scale_inertia_v6 * 2 * M_raw_single;
end

F_flex_lift = 0;
F_flex_thrust = 0;
F_flex_drag = 0;
if enable_flex
    F_flex_lift = scale_flex_v6 * (dL_flex_avg_total + dL_flex_max_total * sin(phase));
    F_flex_thrust = scale_flex_v6 * (0.2*dT_flex_max_total + dT_flex_max_total * sin(phase));
    F_flex_drag = scale_flex_v6 * (0.2*dD_flex_max_total + dD_flex_max_total * sin(phase));
end

F_wake = 0;
if enable_wake
    F_wake = scale_wake_v6 * (Kwc1_total*sin(wing_phi) + Kwc2_total*cos(wing_phi) ...
        + Kwc3_total*sin(2*wing_phi) + Kwc4_total*cos(2*wing_phi));
end

Mx_flex = l_roll * 0.1 * F_flex_lift;
My_flex = M_inertia_pitch + l_pitch * (F_flex_lift + 0.2*F_flex_drag);
Mz_flex = l_yaw * (F_flex_thrust + F_wake);

Mx_flex = local_sat(Mx_flex, M_flex_limit);
My_flex = local_sat(My_flex, M_flex_limit);
Mz_flex = local_sat(Mz_flex, M_flex_limit);

out.F_inertia = F_inertia;
out.M_inertia_pitch = M_inertia_pitch;
out.F_flex_lift = F_flex_lift;
out.F_flex_thrust = F_flex_thrust;
out.F_flex_drag = F_flex_drag;
out.F_wake = F_wake;
out.Mx_flex = Mx_flex;
out.My_flex = My_flex;
out.Mz_flex = Mz_flex;
end

function y = local_sat(x, lim)
if x > lim
    y = lim;
elseif x < -lim
    y = -lim;
else
    y = x;
end
end

function dx = flapping_wing_attitude_dynamics_v6(t, x, enable_inertia, enable_flex, enable_wake)
% Simplified six-state flapping-wing attitude dynamics.

p = x(4);
q = x(5);
r = x(6);

M_ctrl = flapping_wing_controller_v6(x);
flex = flapping_wing_flexible_forces_v6(t, enable_inertia, enable_flex, enable_wake);

Mx_total = M_ctrl(1) + flex.Mx_flex - v6_param('Dx', 0.08) * p;
My_total = M_ctrl(2) + flex.My_flex - v6_param('Dy', 0.10) * q;
Mz_total = M_ctrl(3) + flex.Mz_flex - v6_param('Dz', 0.12) * r;

p_dot = Mx_total / v6_param('Jx', 0.045);
q_dot = My_total / v6_param('Jy', 0.055);
r_dot = Mz_total / v6_param('Jz', 0.070);

roll_dot = p;
pitch_dot = q;
yaw_dot = r;

dx = [roll_dot; pitch_dot; yaw_dot; p_dot; q_dot; r_dot];
end

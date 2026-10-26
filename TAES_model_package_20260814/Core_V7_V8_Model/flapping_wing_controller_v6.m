function M_ctrl = flapping_wing_controller_v6(x)
% Simple saturated PD attitude controller for the V6 plant.

roll = x(1);
pitch = x(2);
yaw = x(3);
p = x(4);
q = x(5);
r = x(6);

Mx = v6_param('Kp_roll', 0.8) * (v6_param('roll_ref', 0) - roll) - v6_param('Kd_roll', 0.25) * p;
My = v6_param('Kp_pitch', 0.8) * (v6_param('pitch_ref', 0) - pitch) - v6_param('Kd_pitch', 0.25) * q;
Mz = v6_param('Kp_yaw', 0.6) * (v6_param('yaw_ref', 0) - yaw) - v6_param('Kd_yaw', 0.20) * r;

lim = v6_param('M_control_limit', 1.5);
M_ctrl = [local_sat(Mx, lim); local_sat(My, lim); local_sat(Mz, lim)];
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

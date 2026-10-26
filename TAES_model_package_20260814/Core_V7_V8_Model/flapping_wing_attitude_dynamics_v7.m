function dx = flapping_wing_attitude_dynamics_v7(t, x, enable_inertia, enable_flex, enable_wake)
% V7 wrapper for Simulink-compatible dynamics.

dx = flapping_wing_attitude_dynamics_v6(t, x, enable_inertia, enable_flex, enable_wake);
end

%% init_flapping_wing_v6_params.m
% Parameters for simplified flexible flapping-wing attitude plant.

clearvars -except KEEP_WORKSPACE_FLAG

%% Geometry and material parameters from flexible-wing FSI paper approximation
S_single = 0.069;        % m^2, single wing
S_total  = 0.138;        % m^2, two wings
R_wing   = 0.5;          % m
c_wing   = 0.2;          % m
t_wing   = 0.001;        % m
rho_wing = 950;          % kg/m^3
rho_air  = 1.225;        % kg/m^3

%% Flapping motion
f_flap = 5;              % Hz
A0 = pi/4;               % rad, flapping amplitude
B0 = 5*pi/180;           % rad, torsion amplitude
V_inf = 5;               % m/s, consistent with FSI data

%% Approximate wing inertia
m_wing_single = rho_wing * S_single * t_wing;
J_phi_wing = m_wing_single * R_wing^2 / 3;
r_cp = 0.7 * R_wing;

phi_ddot_max = A0 * (2*pi*f_flap)^2;
M_inertia_max_single = J_phi_wing * phi_ddot_max;
F_inertia_max_single = M_inertia_max_single / r_cp;

%% Flexible aerodynamic correction from FSI paper approximation
dL_flex_max_single = -1.75;     % N, 200 MPa relative to 2000 MPa
dL_flex_avg_single = -0.223;    % N
dT_flex_max_single = 7.95;      % N
dD_flex_max_single = -2.92;     % N

dL_flex_max_total = 2 * dL_flex_max_single;
dL_flex_avg_total = 2 * dL_flex_avg_single;
dT_flex_max_total = 2 * dT_flex_max_single;
dD_flex_max_total = 2 * dD_flex_max_single;

%% Wake compensation approximation
Kwc1_total = 2 * 0.2 * dT_flex_max_single;
Kwc2_total = 2 * 0.1 * dT_flex_max_single;
Kwc3_total = 2 * 0.1 * dT_flex_max_single;
Kwc4_total = 2 * 0.05 * dT_flex_max_single;

%% Vehicle attitude inertia
Jx = 0.045;       % kg*m^2
Jy = 0.055;       % kg*m^2
Jz = 0.070;       % kg*m^2

%% Rotational damping
Dx = 0.08;
Dy = 0.10;
Dz = 0.12;

%% Moment arms
l_roll  = 0.20;   % m
l_pitch = 0.15;   % m
l_yaw   = 0.10;   % m

%% Controller gains
Kp_roll = 0.8;
Kd_roll = 0.25;

Kp_pitch = 0.8;
Kd_pitch = 0.25;

Kp_yaw = 0.6;
Kd_yaw = 0.20;

%% Saturation
M_control_limit = 1.5;    % N*m
M_flex_limit = 0.5;       % N*m

%% Flexible effect scales
scale_inertia_v6 = 0.05;
scale_flex_v6 = 0.05;
scale_wake_v6 = 0.05;

%% Simulation settings
t_final_v6 = 5;
dt_v6 = 0.001;
max_auto_tune_attempts_v6 = 5;
divergence_angle_limit_deg_v6 = 120;

%% Reference attitude, rad
roll_ref = 0;
pitch_ref = 0;
yaw_ref = 0;

%% Initial attitude, rad
roll0 = 5*pi/180;
pitch0 = 8*pi/180;
yaw0 = 5*pi/180;

p0 = 0;
q0 = 0;
r0 = 0;

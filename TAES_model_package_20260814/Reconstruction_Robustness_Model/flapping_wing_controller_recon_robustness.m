function [M_c, M_0, M_comp_raw, M_comp, saturation_flag] = ...
    flapping_wing_controller_recon_robustness(x, M_ifa_hat)
% Preserve the tuned V8 PD controller and vary only reconstruction feedback.

M_0 = flapping_wing_controller_v6(x);
gain = v6_param('recon_gain_vector_v8', [0.3;0;0.3]);
gain = gain(:);
if isscalar(gain), gain = repmat(gain, 3, 1); end

M_comp_raw = -gain .* M_ifa_hat(:);
comp_limit = v6_param('Mcomp_limit_v8', 0.15);
M_comp = local_sat_vector(M_comp_raw, comp_limit);

control_limit = v6_param('M_control_limit', 1.5);
outer_raw = M_0 + M_comp;
M_c = local_sat_vector(outer_raw, control_limit);
saturation_flag = double(abs(outer_raw) > control_limit * (1 + 1e-12));
end

function y = local_sat_vector(x, limit)
y = min(max(x, -limit), limit);
end

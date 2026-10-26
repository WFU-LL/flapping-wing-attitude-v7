function [M_c, M_0, M_comp, saturation_flag] = flapping_wing_controller_v8(x, M_ifa_hat)
% Preserve the V7 PD moment and add bounded model-assisted compensation.

M_0 = flapping_wing_controller_v6(x);
enabled = logical(v6_param('enable_compensation_v8', 0));

if enabled
    gain = v6_param('Kcomp_mifa_v8', [0.90; 0.90; 0.90]);
    gain = gain(:);
    if isscalar(gain)
        gain = repmat(gain, 3, 1);
    end
    comp_limit = v6_param('Mcomp_limit_v8', 0.50);
    M_comp = local_sat_vector(-gain .* M_ifa_hat(:), comp_limit);
else
    M_comp = zeros(3, 1);
end

control_limit = v6_param('M_control_limit', 1.5);
M_c = local_sat_vector(M_0 + M_comp, control_limit);
saturation_flag = double(abs(M_c) >= control_limit * (1 - 1e-12));
end

function y = local_sat_vector(x, limit)
y = min(max(x, -limit), limit);
end


function [M_hat_raw, M_delayed, noise_value] = ...
    recon_robustness_estimate_v8(t, enable_inertia, enable_flex, enable_wake)
% Apply imperfections only to the reconstructed IFA moment branch.

delay_s = max(0, v6_param('recon_delay_ms_v8', 0)) / 1000;
t_delayed = max(0, t - delay_s);
flex_delayed = flapping_wing_flexible_forces_v6(t_delayed, ...
    enable_inertia, enable_flex, enable_wake);
M_delayed = [flex_delayed.Mx_flex; flex_delayed.My_flex; ...
    flex_delayed.Mz_flex];

delta = v6_param('recon_delta_v8', zeros(3,1));
delta = delta(:);
if isscalar(delta), delta = repmat(delta, 3, 1); end

noise = v6_param('recon_noise_values_v8', zeros(1,3));
fs = v6_param('recon_noise_fs_v8', 1000);
idx = floor(max(t, 0) * fs + 1e-10) + 1;
idx = min(max(idx, 1), size(noise, 1));
noise_value = noise(idx, :).';

M_hat_raw = (1 + delta) .* M_delayed + noise_value;
end

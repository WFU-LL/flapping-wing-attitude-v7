function data = extract_recon_robustness_simout(simout)
% Extract named arrays from the 42-channel reconstruction-study output.

if isa(simout, 'timeseries')
    data.t = simout.Time(:);
    y = squeeze(simout.Data);
else
    data.t = simout.time(:);
    y = squeeze(simout.signals.values);
end
if size(y,1) ~= numel(data.t), y = y.'; end

data.x = y(:,1:6);
data.force_terms = y(:,7:15);
data.M_0 = y(:,16:18);
data.M_ifa = y(:,19:21);
data.M_hat_raw = y(:,22:24);
data.M_ifa_hat = y(:,25:27);
data.M_comp_raw = y(:,28:30);
data.M_comp = y(:,31:33);
data.M_c = y(:,34:36);
data.M_dist = y(:,37:39);
data.saturation_flag = y(:,40:42);
end

function data = extract_v8_simout(simout_v8)
% Extract named arrays from the V8 33-channel logged output.

if isa(simout_v8, 'timeseries')
    data.t = simout_v8.Time(:);
    y = squeeze(simout_v8.Data);
else
    data.t = simout_v8.time(:);
    y = squeeze(simout_v8.signals.values);
end
if size(y, 1) ~= numel(data.t)
    y = y.';
end

data.x = y(:, 1:6);
data.force_terms = y(:, 7:15);
data.M_0 = y(:, 16:18);
data.M_ifa_hat = y(:, 19:21);
data.M_comp = y(:, 22:24);
data.M_c = y(:, 25:27);
data.M_dist = y(:, 28:30);
data.saturation_flag = y(:, 31:33);
data.M_ifa = data.force_terms(:, 7:9);
end


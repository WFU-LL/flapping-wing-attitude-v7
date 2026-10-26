function [t, x, F_terms, M_ctrl] = extract_v7_simout(simout_v7)
% Extract V7 state and term arrays from the S-function To Workspace output.

if isa(simout_v7, 'timeseries')
    t = simout_v7.Time;
    y = squeeze(simout_v7.Data);
else
    t = simout_v7.time;
    y = squeeze(simout_v7.signals.values);
end

if size(y, 1) ~= length(t)
    y = y';
end

x = y(:, 1:6);
F_terms = y(:, 7:15);
M_ctrl = y(:, 16:18);
end

function value = v6_param(name, default_value)
% Read V6 parameters from the base workspace.

if evalin('base', ['exist(''', name, ''', ''var'')'])
    value = evalin('base', name);
else
    value = default_value;
end
end

function flapping_wing_attitude_sfun_v7(block)
% Continuous-state Simulink implementation of the V7 flapping-wing attitude Plant.

setup(block);
end

function setup(block)
block.NumInputPorts = 0;
block.NumOutputPorts = 1;
block.NumContStates = 6;

block.OutputPort(1).Dimensions = 18;
block.OutputPort(1).DatatypeID = 0;
block.OutputPort(1).Complexity = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

block.SampleTimes = [0 0];
block.SimStateCompliance = 'DefaultSimState';

block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Outputs', @Outputs);
end

function InitializeConditions(block)
x0 = v7_param('x0_v7', zeros(6, 1));
block.ContStates.Data = x0(:);
end

function Derivatives(block)
t = block.CurrentTime;
x = block.ContStates.Data;
[enable_inertia, enable_flex, enable_wake] = switches();
block.Derivatives.Data = flapping_wing_attitude_dynamics_v7(t, x, ...
    enable_inertia, enable_flex, enable_wake);
end

function Outputs(block)
t = block.CurrentTime;
x = block.ContStates.Data;
[enable_inertia, enable_flex, enable_wake] = switches();
terms = flapping_wing_flexible_forces_v7(t, enable_inertia, enable_flex, enable_wake);
ctrl = flapping_wing_controller_v6(x);
block.OutputPort(1).Data = [x(:); terms(:); ctrl(:)];
end

function [enable_inertia, enable_flex, enable_wake] = switches()
enable_inertia = v7_param('enable_inertia_v7', 0);
enable_flex = v7_param('enable_flex_v7', 0);
enable_wake = v7_param('enable_wake_v7', 0);
end

function value = v7_param(name, default_value)
if evalin('base', ['exist(''', name, ''', ''var'')'])
    value = evalin('base', name);
else
    value = default_value;
end
end

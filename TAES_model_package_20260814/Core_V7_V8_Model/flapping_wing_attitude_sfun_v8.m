function flapping_wing_attitude_sfun_v8(block)
% Continuous-state Simulink implementation of the V8 compensation model.

setup(block);
end

function setup(block)
block.NumInputPorts = 0;
block.NumOutputPorts = 1;
block.NumContStates = 6;
block.OutputPort(1).Dimensions = 33;
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
x0 = v6_param('x0_v8', zeros(6, 1));
block.ContStates.Data = x0(:);
end

function Derivatives(block)
block.Derivatives.Data = flapping_wing_attitude_dynamics_v8( ...
    block.CurrentTime, block.ContStates.Data);
end

function Outputs(block)
[~, s] = flapping_wing_attitude_dynamics_v8( ...
    block.CurrentTime, block.ContStates.Data);
block.OutputPort(1).Data = [s.x; s.terms; s.M_0; s.M_ifa_hat; ...
    s.M_comp; s.M_c; s.M_dist; s.saturation_flag];
end

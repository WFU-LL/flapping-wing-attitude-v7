function flapping_wing_attitude_sfun_recon_robustness(block)
% Continuous-state S-function for the isolated reconstruction study.

setup(block);
end

function setup(block)
block.NumInputPorts = 0;
block.NumOutputPorts = 1;
block.NumContStates = 9;
block.OutputPort(1).Dimensions = 42;
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
x0 = v6_param('x0_v8', zeros(6,1));
enable_inertia = v6_param('enable_inertia_v8', 0);
enable_flex = v6_param('enable_flex_v8', 0);
enable_wake = v6_param('enable_wake_v8', 0);
M_hat_raw = recon_robustness_estimate_v8(0, ...
    enable_inertia, enable_flex, enable_wake);
block.ContStates.Data = [x0(:); M_hat_raw(:)];
end

function Derivatives(block)
block.Derivatives.Data = flapping_wing_attitude_dynamics_recon_robustness( ...
    block.CurrentTime, block.ContStates.Data);
end

function Outputs(block)
[~, s] = flapping_wing_attitude_dynamics_recon_robustness( ...
    block.CurrentTime, block.ContStates.Data);
block.OutputPort(1).Data = [s.x; s.terms; s.M_0; s.M_ifa; ...
    s.M_hat_raw; s.M_hat_used; s.M_comp_raw; s.M_comp; ...
    s.M_c; s.M_dist; s.saturation_flag];
end

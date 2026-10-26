function flapping_wing_attitude_sfun_recon_ensemble(block)
% Continuous-state S-function batching independent matched samples.

setup(block);
end

function setup(block)
N=v6_param('recon_batch_N_v8',1);
block.NumInputPorts=0;
block.NumOutputPorts=1;
block.NumContStates=9*N;
block.OutputPort(1).Dimensions=42*N;
block.OutputPort(1).DatatypeID=0;
block.OutputPort(1).Complexity='Real';
block.OutputPort(1).SamplingMode='Sample';
block.SampleTimes=[0 0];
block.SimStateCompliance='DefaultSimState';
block.RegBlockMethod('InitializeConditions',@InitializeConditions);
block.RegBlockMethod('Derivatives',@Derivatives);
block.RegBlockMethod('Outputs',@Outputs);
end

function InitializeConditions(block)
P=v6_param('recon_batch_params_v8',struct('N',1,'x0',zeros(6,1)));
N=P.N;
dummy=[P.x0(:);zeros(3*N,1)];
[~,signals]=flapping_wing_attitude_dynamics_recon_ensemble(0,dummy);
Mraw_matrix=signals(22:24,:);
block.ContStates.Data=[P.x0(:);Mraw_matrix(:)];
end

function Derivatives(block)
block.Derivatives.Data=flapping_wing_attitude_dynamics_recon_ensemble( ...
    block.CurrentTime,block.ContStates.Data);
end

function Outputs(block)
[~,signals]=flapping_wing_attitude_dynamics_recon_ensemble( ...
    block.CurrentTime,block.ContStates.Data);
block.OutputPort(1).Data=signals(:);
end

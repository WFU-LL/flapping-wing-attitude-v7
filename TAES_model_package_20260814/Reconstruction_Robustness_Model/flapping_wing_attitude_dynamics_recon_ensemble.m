function [dz,signals] = flapping_wing_attitude_dynamics_recon_ensemble(t,z)
% Vectorized independent copies of the unchanged V8 reduced-order dynamics.

persistent cached_token P noise noise_fs
token=v6_param('recon_batch_token_v8',-1);
if isempty(cached_token) || cached_token~=token
    P=v6_param('recon_batch_params_v8',struct());
    noise=v6_param('recon_batch_noise_values_v8',zeros(1,3));
    noise_fs=v6_param('recon_batch_noise_fs_v8',1000);
    cached_token=token;
end
N=P.N;
x=reshape(z(1:6*N),6,N);
M_lpf=reshape(z(6*N+1:9*N),3,N);

[M_ifa,terms]=local_force_terms(t,P);
[M_delayed,~]=local_force_terms(max(0,t-P.delay_s),P);
idx=min(max(floor(max(t,0)*noise_fs+1e-10)+1,1),size(noise,1));
noise_value=reshape(noise(idx,:),3,N);
M_raw=(1+P.delta).*M_delayed+noise_value;
M_lpf_dot=2*pi*max(P.filter_cutoff_hz,eps).*(M_raw-M_lpf);
if P.use_filter,M_used=M_lpf;else,M_used=M_raw;end

M0=local_sat(P.Kp.*(P.reference-x(1:3,:))-P.Kd.*x(4:6,:), ...
    P.Mcontrol_limit);
Mcomp_raw=-P.gain.*M_used;
Mcomp=local_sat(Mcomp_raw,P.Mcomp_limit);
outer_raw=M0+Mcomp;
Mc=local_sat(outer_raw,P.Mcontrol_limit);
sat=double(abs(outer_raw)>P.Mcontrol_limit*(1+1e-12));
Mdist=local_disturbance(t,P,N);

omega=x(4:6,:);
omega_dot=(Mc+M_ifa+Mdist-P.D.*omega)./P.J;
dx=[omega;omega_dot];
dz=[dx(:);M_lpf_dot(:)];

if nargout>1
    signals=[x;terms;M0;M_ifa;M_raw;M_used;Mcomp_raw;Mcomp;Mc;Mdist;sat];
end
end

function [M,terms]=local_force_terms(t,P)
C=P.constants;N=P.N;
phase=2*pi.*P.f_flap.*t;
wing_phi=P.A0.*sin(phase);
wing_phi_ddot=-P.A0.*(2*pi.*P.f_flap).^2.*sin(phase);
F_inertia=zeros(1,N);M_inertia=zeros(1,N);
if P.enable_inertia
    M_raw=C.J_phi_wing.*wing_phi_ddot;
    F_inertia=2.*P.scale_inertia.*M_raw./C.r_cp;
    M_inertia=2.*P.scale_inertia.*M_raw;
end
lift=zeros(1,N);thrust=zeros(1,N);drag=zeros(1,N);
if P.enable_flex
    lift=P.scale_flex.*(C.dL_flex_avg_total+C.dL_flex_max_total.*sin(phase));
    thrust=P.scale_flex.*(0.2*C.dT_flex_max_total+C.dT_flex_max_total.*sin(phase));
    drag=P.scale_flex.*(0.2*C.dD_flex_max_total+C.dD_flex_max_total.*sin(phase));
end
wake=zeros(1,N);
if P.enable_wake
    wake=P.scale_wake.*(C.Kwc1_total.*sin(wing_phi)+ ...
        C.Kwc2_total.*cos(wing_phi)+C.Kwc3_total.*sin(2*wing_phi)+ ...
        C.Kwc4_total.*cos(2*wing_phi));
end
Mx=local_sat(C.l_roll*0.1.*lift,P.Mflex_limit);
My=local_sat(M_inertia+C.l_pitch.*(lift+0.2.*drag),P.Mflex_limit);
Mz=local_sat(C.l_yaw.*(thrust+wake),P.Mflex_limit);
M=[Mx;My;Mz];
terms=[F_inertia;M_inertia;lift;thrust;drag;wake;M];
end

function M=local_disturbance(t,P,N)
M=zeros(3,N);
switch char(P.external_condition)
    case 'yaw_impulse'
        if t>=P.disturbance_time && t<=P.disturbance_time+P.disturbance_duration
            M(3,:)=P.disturbance_amp;
        end
    case 'multi_axis_sine'
        if t>=P.disturbance_time
            td=t-P.disturbance_time;
            M=repmat(P.disturbance_amp.*[sin(2*pi*2*td); ...
                0.8*sin(2*pi*3*td);0.6*sin(2*pi*4*td)],1,N);
        end
end
end

function y=local_sat(x,limit)
y=min(max(x,-limit),limit);
end

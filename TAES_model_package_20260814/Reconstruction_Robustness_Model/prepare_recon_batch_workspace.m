function [P,noise_meta] = prepare_recon_batch_workspace(cfg,samples, ...
    mechanism_case,controller,scenario)
% Prepare N independent parameter sets for one direct-Simulink batch.

if ~istable(samples),samples=struct2table(samples);end
N=height(samples);
case_idx=find(strcmp(cfg.cases(:,1),mechanism_case),1);
if isempty(case_idx),error('ReconStudy:UnknownCase',mechanism_case);end

P=struct();
P.N=N;
P.J=[samples.Jx.';samples.Jy.';samples.Jz.'];
P.D=[samples.Dx.';samples.Dy.';samples.Dz.'];
P.scale_inertia=samples.scale_inertia_v6.';
P.scale_flex=samples.scale_flex_v6.';
P.scale_wake=samples.scale_wake_v6.';
P.f_flap=samples.f_flap.';
P.A0=samples.A0.';
P.x0=[deg2rad(samples.initial_roll_deg).'; ...
    deg2rad(samples.initial_pitch_deg).';deg2rad(samples.initial_yaw_deg).'; ...
    samples.initial_p.';samples.initial_q.';samples.initial_r.'];
P.enable_inertia=cfg.cases{case_idx,2};
P.enable_flex=cfg.cases{case_idx,3};
P.enable_wake=cfg.cases{case_idx,4};
P.delta=repmat(scenario.delta,3,1);
if ~isscalar(scenario.delta),P.delta=scenario.delta(:);end
P.delay_s=scenario.delay_ms/1000;
P.filter_cutoff_hz=scenario.filter_cutoff_hz;
P.external_condition='none';
P.disturbance_amp=v6_param('disturbance_moment_amp_v8',0.05);
P.disturbance_time=v6_param('disturbance_time_v8',1.0);
P.disturbance_duration=v6_param('disturbance_duration_v8',0.10);
P.Mcomp_limit=v6_param('Mcomp_limit_v8',0.15);
P.Mcontrol_limit=v6_param('M_control_limit',1.5);
P.Mflex_limit=v6_param('M_flex_limit',0.5);
P.reference=[v6_param('roll_ref',0);v6_param('pitch_ref',0); ...
    v6_param('yaw_ref',0)];
P.Kp=[v6_param('Kp_roll',0.8);v6_param('Kp_pitch',0.8); ...
    v6_param('Kp_yaw',0.6)];
P.Kd=[v6_param('Kd_roll',0.25);v6_param('Kd_pitch',0.25); ...
    v6_param('Kd_yaw',0.20)];
P.constants=local_constants();

switch char(controller)
    case 'C0_baseline_PD'
        P.gain=[0;0;0];P.use_filter=false;
    case 'C1_selective'
        P.gain=[scenario.k;0;scenario.k];P.use_filter=false;
    case 'C2_all_axis'
        P.gain=repmat(scenario.k,3,1);P.use_filter=false;
    case 'C3_selective_LPF'
        P.gain=[scenario.k;0;scenario.k];P.use_filter=true;
    otherwise
        error('ReconStudy:UnknownController',controller);
end

fs=cfg.noise_generation_hz;
t_noise=(0:1/fs:cfg.stop_time).';
noise_flat=zeros(numel(t_noise),3*N);
actual_rms=zeros(N,3);
target_rms=zeros(N,3);
seeds=zeros(N,1);
for i=1:N
    true_mifa=local_true_mifa_grid(t_noise,P,i);
    true_rms=sqrt(mean(true_mifa.^2,1));
    target_rms(i,:)=scenario.noise_rms_fraction.*true_rms;
    seeds(i)=cfg.seed+samples.sample_id(i);
    if scenario.noise_rms_fraction>0
        stream=RandStream('mt19937ar','Seed',seeds(i));
        white=randn(stream,numel(t_noise),3);
        alpha=exp(-2*pi*cfg.noise_bandlimit_hz/fs);
        shaped=filter(1-alpha,[1 -alpha],white);
        shaped=shaped-mean(shaped,1);
        shaped_rms=sqrt(mean(shaped.^2,1));
        noise=shaped.*(target_rms(i,:)./max(shaped_rms,eps));
    else
        noise=zeros(numel(t_noise),3);
    end
    columns=(i-1)*3+(1:3);
    noise_flat(:,columns)=noise;
    actual_rms(i,:)=sqrt(mean(noise.^2,1));
end

noise_meta=struct('seed',seeds,'actual_rms',actual_rms, ...
    'target_rms',target_rms,'generation_hz',fs, ...
    'bandlimit_hz',cfg.noise_bandlimit_hz);
assignin('base','recon_batch_N_v8',N);
assignin('base','recon_batch_params_v8',P);
assignin('base','recon_batch_noise_values_v8',noise_flat);
assignin('base','recon_batch_noise_fs_v8',fs);
token=v6_param('recon_batch_token_v8',0)+1;
assignin('base','recon_batch_token_v8',token);
end

function C=local_constants()
names={'J_phi_wing','r_cp','dL_flex_avg_total','dL_flex_max_total', ...
    'dT_flex_max_total','dD_flex_max_total','Kwc1_total','Kwc2_total', ...
    'Kwc3_total','Kwc4_total','l_roll','l_pitch','l_yaw'};
defaults={0.005,0.35,-0.446,-3.5,15.9,-5.84,3.18,1.59,1.59, ...
    0.795,0.20,0.15,0.10};
for i=1:numel(names),C.(names{i})=v6_param(names{i},defaults{i});end
end

function M=local_true_mifa_grid(t,P,index)
C=P.constants;
phase=2*pi*P.f_flap(index).*t;
wing_phi=P.A0(index).*sin(phase);
wing_phi_ddot=-P.A0(index).*(2*pi*P.f_flap(index))^2.*sin(phase);
M_inertia=zeros(size(t));
if P.enable_inertia
    M_inertia=P.scale_inertia(index).*2*C.J_phi_wing.*wing_phi_ddot;
end
lift=zeros(size(t));thrust=zeros(size(t));drag=zeros(size(t));
if P.enable_flex
    lift=P.scale_flex(index).*(C.dL_flex_avg_total+C.dL_flex_max_total.*sin(phase));
    thrust=P.scale_flex(index).*(0.2*C.dT_flex_max_total+C.dT_flex_max_total.*sin(phase));
    drag=P.scale_flex(index).*(0.2*C.dD_flex_max_total+C.dD_flex_max_total.*sin(phase));
end
wake=zeros(size(t));
if P.enable_wake
    wake=P.scale_wake(index).*(C.Kwc1_total.*sin(wing_phi)+ ...
        C.Kwc2_total.*cos(wing_phi)+C.Kwc3_total.*sin(2*wing_phi)+ ...
        C.Kwc4_total.*cos(2*wing_phi));
end
Mx=local_sat(C.l_roll*0.1.*lift,P.Mflex_limit);
My=local_sat(M_inertia+C.l_pitch.*(lift+0.2.*drag),P.Mflex_limit);
Mz=local_sat(C.l_yaw.*(thrust+wake),P.Mflex_limit);
M=[Mx My Mz];
end

function y=local_sat(x,limit)
y=min(max(x,-limit),limit);
end

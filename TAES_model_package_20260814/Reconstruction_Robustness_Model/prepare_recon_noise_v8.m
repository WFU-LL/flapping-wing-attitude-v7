function meta = prepare_recon_noise_v8(cfg, sample_id, mechanism_case, gamma)
% Generate shared 1 kHz, 20 Hz-band-limited reconstruction noise.

case_idx = find(strcmp(cfg.cases(:,1), mechanism_case), 1);
if isempty(case_idx)
    error('ReconStudy:UnknownCase', 'Unknown mechanism case: %s', mechanism_case);
end
enable_inertia = cfg.cases{case_idx,2};
enable_flex = cfg.cases{case_idx,3};
enable_wake = cfg.cases{case_idx,4};

fs = cfg.noise_generation_hz;
t_noise = (0:1/fs:cfg.stop_time).';
M_true = zeros(numel(t_noise), 3);
for i = 1:numel(t_noise)
    flex = flapping_wing_flexible_forces_v6(t_noise(i), ...
        enable_inertia, enable_flex, enable_wake);
    M_true(i,:) = [flex.Mx_flex, flex.My_flex, flex.Mz_flex];
end
true_rms = sqrt(mean(M_true.^2, 1));

noise_seed = cfg.seed + double(sample_id);
if gamma <= 0
    noise = zeros(size(M_true));
else
    stream = RandStream('mt19937ar', 'Seed', noise_seed);
    white = randn(stream, size(M_true));
    alpha = exp(-2*pi*cfg.noise_bandlimit_hz/fs);
    shaped = filter(1-alpha, [1 -alpha], white);
    shaped = shaped - mean(shaped, 1);
    shaped_rms = sqrt(mean(shaped.^2, 1));
    noise = zeros(size(shaped));
    for axis = 1:3
        if shaped_rms(axis) > 0 && true_rms(axis) > 0
            noise(:,axis) = shaped(:,axis) .* ...
                (gamma * true_rms(axis) / shaped_rms(axis));
        end
    end
end

actual_rms = sqrt(mean(noise.^2, 1));
assignin('base', 'recon_noise_values_v8', noise);
assignin('base', 'recon_noise_fs_v8', fs);
assignin('base', 'recon_noise_time_v8', t_noise);
assignin('base', 'recon_noise_seed_v8', noise_seed);
assignin('base', 'recon_noise_actual_rms_v8', actual_rms);

meta = struct('seed', noise_seed, 'actual_rms', actual_rms, ...
    'target_rms', gamma .* true_rms, 'true_rms', true_rms, ...
    'generation_hz', fs, 'bandlimit_hz', cfg.noise_bandlimit_hz);
end

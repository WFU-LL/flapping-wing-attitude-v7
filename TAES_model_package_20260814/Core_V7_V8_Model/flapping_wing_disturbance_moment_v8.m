function M_dist = flapping_wing_disturbance_moment_v8(t)
% External validation disturbance; it is not included in M_IFA estimation.

disturbance_case = v6_param('disturbance_case_v8', 'none');
amp = v6_param('disturbance_moment_amp_v8', 0.05);
t0 = v6_param('disturbance_time_v8', 1.0);
duration = v6_param('disturbance_duration_v8', 0.10);
M_dist = zeros(3, 1);

switch char(disturbance_case)
    case 'pitch_impulse'
        if t >= t0 && t <= t0 + duration
            M_dist(2) = amp;
        end
    case 'yaw_impulse'
        if t >= t0 && t <= t0 + duration
            M_dist(3) = amp;
        end
    case 'multi_axis_sine'
        if t >= t0
            td = t - t0;
            M_dist = amp * [sin(2*pi*2*td); ...
                0.8*sin(2*pi*3*td); 0.6*sin(2*pi*4*td)];
        end
    case 'none'
        % No external moment.
    otherwise
        error('V8:UnknownDisturbance', 'Unknown V8 disturbance case: %s', ...
            char(disturbance_case));
end
end


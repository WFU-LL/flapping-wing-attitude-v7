function analyze_recon_robustness()
% Regenerate statistics, tables, reports, and figures from final CSV data.

study_root = fileparts(mfilename('fullpath'));
python_script = fullfile(study_root, 'analyze_reconstruction_robustness.py');
python_candidates = {
    fullfile(getenv('USERPROFILE'), '.cache', 'codex-runtimes', ...
        'codex-primary-runtime', 'dependencies', 'python', 'python.exe')
    'python'
    'py -3'
};

status = 1;
last_output = '';
for i = 1:numel(python_candidates)
    candidate = python_candidates{i};
    if contains(candidate, filesep) && ~exist(candidate, 'file')
        continue;
    end
    command = sprintf('%s "%s"', quote_executable(candidate), python_script);
    [status, last_output] = system(command);
    if status == 0
        break;
    end
end
if status ~= 0
    error('ReconStudy:AnalysisFailed', ...
        'Python analysis failed. Last output:\n%s', last_output);
end
fprintf('%s', last_output);
plot_reconstruction_robustness_results();
fprintf('RECON_ANALYSIS_RESULT=PASS\n');
end

function value = quote_executable(candidate)
if contains(candidate, filesep)
    value = ['"' candidate '"'];
else
    value = candidate;
end
end

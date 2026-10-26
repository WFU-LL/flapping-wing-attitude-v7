function package_root = setup_model_paths()
% Add the packaged V7/V8 and reconstruction-robustness model folders.

package_root = fileparts(mfilename('fullpath'));
addpath(fullfile(package_root, 'Core_V7_V8_Model'));
addpath(fullfile(package_root, 'Reconstruction_Robustness_Model'));

fprintf('Model package paths added from:\n%s\n', package_root);
end

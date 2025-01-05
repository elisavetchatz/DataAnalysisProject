% Read the data from the file
current_file_path = mfilename('fullpath');
[parent_folder, ~, ~] = fileparts(fileparts(current_file_path));
data_path = fullfile(parent_folder, 'TMS.xlsx');

% Check if the file exists
if ~exist(data_path, 'file')
    error('The file TMS.xlsx does not exist in the specified path: %s', data_path);
end

% Load the data into a table
data = readtable(data_path);

% Perform linear and polynomial analysis for TMS = 0 (without TMS)
fprintf('\nAnalysis for TMS = 0 (Without TMS):\n');
analyze_linear(data, 0);
analyze_polynomial(data, 0);

% Perform linear and polynomial analysis for TMS = 1 (with TMS)
fprintf('\nAnalysis for TMS = 1 (With TMS):\n');
analyze_linear(data, 1);
analyze_polynomial(data, 1);


% MATLAB Analysis for the Relationship Between EDduration and Setup

% Analysis Results:
% TMS = 0 (Without TMS):
% - Linear model: R^2 = 0.006, no significant correlation between EDduration and Setup.
% - Polynomial models:
%   Degree 2: R^2 = 0.084
%   Degree 3: R^2 = 0.216
% - Conclusion: Polynomial models improve the fit, but the dependency remains weak.

% TMS = 1 (With TMS):
% - Linear model: R^2 = 0.084, significant correlation between EDduration and Setup.
% - Polynomial models:
%   Degree 2: R^2 = 0.259
%   Degree 3: R^2 = 0.353
% - Conclusion: Polynomial models improve the fit significantly, revealing a stronger relationship.

% Overall Conclusions:
% - The dependency between EDduration and Setup is more pronounced when TMS is applied.
% - Linear models are insufficient in both cases.
% - Polynomial models (especially of degree 3) provide better fit and uncover nonlinear relationships.

% Task 5: Regression Analysis of ED Duration by Setup

% Read the data from the file
current_file_path = mfilename('fullpath');
[parent_folder, ~, ~] = fileparts(fileparts(current_file_path));
data_path = fullfile(parent_folder, 'TMS.xlsx');
if ~exist(data_path, 'file')
    error('The file TMS.xlsx does not exist in the specified path: %s', data_path);
end
data = readtable(data_path);

% Separate data into two cases: with and without TMS
data_noTMS = data(data.TMS == 0, :);
data_withTMS = data(data.TMS == 1, :);

% Initialize results struct array
results = struct('Case', '', 'Rsquared', 0, 'AdjustedRsquared', 0, 'MeanResidual', 0, 'StdResidual', 0);

% Perform regression for both cases
results(1) = perform_regression(data_noTMS, 'No TMS');
results(2) = perform_regression(data_withTMS, 'With TMS');

% Prepare results table for display
result_table = table({results.Case}', [results.Rsquared]', [results.AdjustedRsquared]', ...
    [results.MeanResidual]', [results.StdResidual]', ...
    'VariableNames', {'Case', 'R_squared', 'Adjusted_R_squared', 'Mean_Residual', 'Std_Residual'});

% Display results in command window
fprintf('\n===========================\n');
fprintf('Regression Analysis Results:\n');
fprintf('===========================\n');
for i = 1:height(result_table)
    fprintf('Case: %s\n', result_table.Case{i});
    fprintf('  R-squared: %.4f\n', result_table.R_squared(i));
    fprintf('  Adjusted R-squared: %.4f\n', result_table.Adjusted_R_squared(i));
    fprintf('  Mean Residual: %.4f\n', result_table.Mean_Residual(i));
    fprintf('  Std Residual: %.4f\n', result_table.Std_Residual(i));
    fprintf('---------------------------\n');
end

% Display results in a uitable
f = figure('Name', 'Regression Results', 'Position', [100, 100, 700, 250]);
uitable('Parent', f, 'Data', result_table{:,:}, 'ColumnName', result_table.Properties.VariableNames, ...
    'Position', [20, 20, 660, 200]);

% Decision on polynomial regression
fprintf('\n===========================\n');
fprintf('Polynomial Regression Suggestion:\n');
fprintf('===========================\n');
for i = 1:height(result_table)
    if result_table.Adjusted_R_squared(i) < 0.5
        fprintf('For case %s, consider exploring polynomial regression.\n', result_table.Case{i});
    else
        fprintf('For case %s, the linear model seems sufficient.\n', result_table.Case{i});
    end
end

% Read the data from the file
current_file_path = mfilename('fullpath');
[parent_folder, ~, ~] = fileparts(fileparts(current_file_path));
data_path = fullfile(parent_folder, 'TMS.xlsx');
if ~exist(data_path, 'file')
    error('The file TMS.xlsx does not exist in the specified path: %s', data_path);
end
data = readtable(data_path);  

% Filter data to include only rows where TMS == 0 (without TMS)
data_without_TMS = data(data.TMS == 0, :);

% Get EDduration without TMS
ED_without_TMS = data_without_TMS.EDduration;

% Get Setup as a numeric variable
Setup_numeric = double(categorical(data_without_TMS.Setup));

% Prepare independent variables matrix (predictors)
X = [Setup_numeric]; 

% Dependent variable (EDduration)
y = ED_without_TMS;

% Perform stepwise regression
[bV, sdbV, pvalV, inmodel, stats] = stepwisefit(X, y);

% Extract the intercept
b0 = stats.intercept;

% Display results
disp('Stepwise Regression Results:');
disp('Selected Coefficients:');
disp(bV(inmodel));  % Coefficients of selected predictors
disp('Intercept:');
disp(b0);

% Plot the data and regression line
figure;
scatter(Setup_numeric, y, 'filled');  % Scatter plot for ED_without_TMS
hold on;

% Plot the regression line (using the selected model)
fitted_line = b0 + bV * Setup_numeric;  % Adjust indexing based on predictors in the model
plot(Setup_numeric, fitted_line, '-r', 'LineWidth', 2);

% Add labels and title
title('Stepwise Regression for ED Without TMS by Setup');
xlabel('Setup (Numeric)');
ylabel('ED Without TMS');
hold off;



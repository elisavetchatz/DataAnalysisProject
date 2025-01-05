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

% Get all unique setups for rows where TMS == 0
setups = unique(data_without_TMS.Setup);
num_setups = length(setups);

Setup_numeric = double(categorical(data_without_TMS.Setup));
xM = [ones(length(Setup_numeric), 1), Setup_numeric];
y = ED_without_TMS;

% Fit a linear model for ED_without_TMS by numeric Setup
[b, bint, r, ~, stats] = regress(y, xM);

yhat = b(1) + Setup_numeric * b(2);

% Check if ED duration is correlated with setup
% bint stores a 95% ci 
if bint(2, 1) < 0 && bint(2, 1)
    fprintf("Data is uncorrelated.")
else
    fprintf("Data is correlated.")
end

% Plot the results
figure;
scatter(Setup_numeric, y, 'filled');
hold on;
plot(Setup_numeric, yhat, '-r');
xlabel('Setup (numeric)');
ylabel('EDduration without TMS');
title('Linear Regression of EDduration without TMS by Setup');
legend('Data points', 'Fitted line');
grid on;
hold off;

% Group40Ex8

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

% Extract data with TMS
data_with_TMS = data(data.TMS == 1, :);


% Ensure all columns are numeric
columns_to_convert = {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode', 'preTMS'};
for i = 1:length(columns_to_convert)
    column = columns_to_convert{i};
    if iscell(data_with_TMS_Spike.(column))
        data_with_TMS_Spike.(column) = cellfun(@(x) str2double(x), data_with_TMS_Spike.(column), 'UniformOutput', false);
        data_with_TMS_Spike.(column) = cell2mat(data_with_TMS_Spike.(column));
    end
end

% Select variables
indepedent_vars = table2array(data_with_TMS_Spike(:, {'Setup', 'Stimuli', 'Intensity', 'Spike', 'Frequency', 'CoilCode', 'preTMS'}));

%% Full model
% We chose to remove the Spike variable (task 6)
data_with_TMS_noSpike = removevars(data_with_TMS_Spike, 'Spike');
X = indepedent_vars;
y = data_with_TMS_noSpike.EDduration;

% Fit the model
lm_full_no_spike = fitlm(X, y);
mse_full_no_spike = lm_full_no_spike.MSE;
r2_full_no_spike = lm_full_no_spike.Rsquared.Adjusted;

%% Stepwise model
[b,~,stats] = stepwisefit(X, y, 'display', 'off');




% Group40Ex8
warning('off', 'all');

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
data_with_TMS = removevars(data_with_TMS, 'Spike');

% Ensure all columns are numeric
columns_to_convert = {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode', 'preTMS'};
for i = 1:length(columns_to_convert)
    column = columns_to_convert{i};
    if iscell(data_with_TMS.(column))
        data_with_TMS.(column) = cellfun(@str2double, data_with_TMS.(column));
    end
end

% Select variables
indepedent_vars = table2array(data_with_TMS(:, columns_to_convert));
EDduration = data_with_TMS.EDduration;

% Centering the data
mx = mean(indepedent_vars);
X = indepedent_vars - mx;
X = zscore(X);
my = mean(EDduration);
y = EDduration - my;
fprintf('Model with preTMS variables\n');
compare_models(X, y);

%% Add postTMS as an independent variable
% Select variables
columns_to_convert = {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode', 'preTMS', 'postTMS'};
for i = 1:length(columns_to_convert)
    column = columns_to_convert{i};
    if iscell(data_with_TMS.(column))
        data_with_TMS.(column) = cellfun(@str2double, data_with_TMS.(column));
    end
end

indepedent_vars = table2array(data_with_TMS(:, columns_to_convert));
EDduration = data_with_TMS.EDduration;

% Center the data
mx = mean(indepedent_vars);
X = indepedent_vars;
X = zscore(X);
my = mean(EDduration);
y = EDduration;
fprintf('Model with preTMS and postTMS variables\n');

compare_models(X, y);

% Conclusions
% Stepwise model has the highest adjusted R^2
% PCR model was chosen to keep 95% of the variance and it performed the worst compared to the other models.
% Συγκριση μοντελων με pcr
% Συγκριση με το task 5

% The model with preTMS and postTMS variables has the highest adjusted R^2
% Which indicates postTMS variable is a significant predictor of EDduration
% αλλάζουν τα μοντελα με την εξτρα μεταβλητη?
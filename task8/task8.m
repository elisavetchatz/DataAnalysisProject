% Group40Ex8
lambda_task6 = 0.1302;
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
indepedent_vars = table2array(data_with_TMS_Spike(:, {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode', 'preTMS'}));
EDduration = data_with_TMS_NoSpike.EDduration;

% Normalize the data
mx = mean(indepedent_vars);
X = indepedent_vars - mx;
y = EDduration - mean(EDduration);

%% Full model
% We chose to remove the Spike variable (task 6)
data_with_TMS_noSpike = removevars(data_with_TMS_Spike, 'Spike');

% Fit the model
lm_full = fitlm(X, y);
mse_full = lm_full_no_spike.MSE;
r2_full_no_spike = lm_full_no_spike.Rsquared.Adjusted;

%% Stepwise model
lm_stepwise = stepwisefit(X, y, 'Verbose', 0);
Y_pred_stepwise= predict(lm_stepwise_train, X);
mse_stepwise = mean((y - Y_pred_stepwise).^2);

%% LASSO
[beta, fitinfo] = lasso(X, y, 'CV', 10);
lambda_optimal = lambda_task6;
[~, ilmin] = min(abs(fitinfo.Lambda - lambda_optimal));
bLASSOV = beta(:, ilmin);
mxV = mean(X);
my = mean(y);
bLASSOV = [my - mxV * bLASSOV; bLASSOV];
yfitLASSOV = [ones(length(y), 1) X] * bLASSOV;
mse_lasso = mean((y - yfitLASSOV).^2);


%% PCR





% Μένει να γινει το pcr 
% Πόσες συνιστώσες να επιλεχθούν?
% Να συγκριθουν τα μοντελα με το pcr 
% Να συγκριθουν με το linear μοντελο της ασκησης 5

% Να ξαναλυθει η ασκηση αλλά
% Να προσθεσουμε σαν ανεξαρτητη μεταβλητη το ΚΑΙ postTMS


% Να διορθώσουμε τον κώδικα για το task 6
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

% Normalize the data
mx = mean(indepedent_vars);
X = indepedent_vars - mx;
my = mean(EDduration);
y = EDduration - my;

%% Full model
% We chose to remove the Spike variable (task 6)
data_with_TMS = removevars(data_with_TMS, 'Spike');

% Fit the model
lm_full = fitlm(X, y);
mse_full = lm_full.MSE;
r2_full_adj = lm_full.Rsquared.Adjusted;

%% Stepwise model
lm_stepwise = stepwiselm(X, y, 'Verbose', 0);
Y_pred_stepwise= predict(lm_stepwise, X);
mse_stepwise = mean((y - Y_pred_stepwise).^2);
r2_stepwise_adj = lm_stepwise.Rsquared.Adjusted;
disp('Stepwise');
disp(r2_stepwise_adj);



%% LASSO
rng(1); % For reproducibility
[beta, fitinfo] = lasso(X, y, 'CV', 10);
lambda_optimal = fitinfo.LambdaMinMSE;
[~, ilmin] = min(abs(fitinfo.Lambda - lambda_optimal));
bLASSOV = beta(:, ilmin);
bLASSOV = [mean(y) - mean(X) * bLASSOV; bLASSOV];
yfitLASSOV = [ones(length(y), 1) X] * bLASSOV;

% Calculate the MSE and R^2
res_lasso = y - yfitLASSOV;
RSS_lasso = sum(res_lasso .^ 2);
mse_lasso = mean(res_lasso .^ 2);
TSS = sum((y - mean(y)) .^ 2);
r2_lasso = 1 - RSS_lasso / TSS;
r2_lasso_adj = 1 - (1 - r2_lasso) * (length(y) - 1) / (length(y) - size(X, 2) - 1);
disp('LASSO');
disp(r2_lasso_adj);

%% PCR
n = length(X);
[PCALoadings, PCAScores, PCAVar] = pca(X,'Economy',false);
% Decide number of components based on the desired variance
desiredVariance = 0.95;
cumVar = cumsum(PCAVar) / sum(PCAVar);
numComponents = find(cumVar >= desiredVariance, 1);

betaPCR = regress(y - mean(y), PCAScores(:, 1:numComponents));
fprintf('PCR: Number of components chosen: %d\n', numComponents);
betaPCR = PCALoadings(:, 1:numComponents) * betaPCR;
betaPCR = [mean(y) - mean(X) * betaPCR; betaPCR];
yfitPCR = [ones(n, 1) X] * betaPCR;

% Calculate the MSE and R^2
RSS_PCR = sum((y - yfitPCR) .^ 2);
mse_PCR = mean((y - yfitPCR) .^ 2);
r2_PCR = 1 - RSS_PCR / TSS;
r2_PCR_adj = 1 - (1 - r2_PCR) * (length(y) - 1) / (length(y) - size(X, 2) - 1);



%% Print the results in a table 
results_table = table({'Full Model'; 'Stepwise Model'; 'LASSO Model'; 'PCR Model'}, ...
                               [mse_full; mse_stepwise; mse_lasso; mse_PCR], ...
                               [r2_full_adj; r2_stepwise_adj; r2_lasso_adj; r2_PCR_adj], ...
                               'VariableNames', {'Model', 'MSE', 'Adjusted_R2'});

disp('Model Comparison Results without Spike:');
disp(results_table); 


% Conclusions
% Stepwise model has the highest adjusted R^2
% PCR model was chosen to keep 95% of the variance and it performed the worst compared to the other models.
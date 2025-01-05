%Group40Ex6

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

%extract data with TMS
data_with_TMS = data(data.TMS == 1, :);

% Check and convert variable types for compatibility
% , δεν ξερω αν δουλευει 100% σωστα αυτο
columns_to_convert = {'Stimuli', 'Intensity', 'Spike', 'Frequency', 'CoilCode'};
for i = 1:length(columns_to_convert)
    column = columns_to_convert{i};
    if iscell(data_with_TMS.(column))
        % Μετατροπή σε αριθμούς και αντικατάσταση μη αριθμητικών με NaN
        data_with_TMS.(column) = cellfun(@(x) str2double(x), data_with_TMS.(column), 'UniformOutput', false);
        data_with_TMS.(column) = cell2mat(data_with_TMS.(column));
    end
end

% select variables
indepedent_vars = data_with_TMS(:, {'Setup', 'Stimuli', 'Intensity', 'Spike', 'Frequency', 'CoilCode'});
EDduration = data_with_TMS.EDduration;

% Handle missing values in Spike
fprintf('Number of missing values in Spike: %d\n', sum(ismissing(indepedent_vars.Spike)));

% ---full model---
lm_full = fitlm(indepedent_vars, EDduration);

%metrics
mse_full = lm_full.MSE;
r2_full = lm_full.Rsquared.Adjusted;

fprintf('Full Model - MSE: %.4f, Adjusted R^2: %.4f\n', mse_full, r2_full);

%---stepwise regression---
lm_stepwise = stepwiselm(indepedent_vars, EDduration);

%metrics
mse_stepwise = lm_stepwise.MSE;
r2_stepwise = lm_stepwise.Rsquared.Adjusted;

fprintf('Stepwise Model - MSE: %.4f, Adjusted R^2: %.4f\n', mse_stepwise, r2_stepwise);

%---LASSO Model---
% Preprocess the data for LASSO
X_lasso = table2array(indepedent_vars);
Y_lasso = EDduration;

% Perform LASSO regression with cross-validation
[beta, fitinfo] = lasso(X_lasso, Y_lasso, 'CV', 10);

%lamda optimal value
lambda_optimal = fitinfo.LambdaMinMSE;

% Selected variables
selected_vars = find(beta(:, fitinfo.IndexMinMSE) ~= 0);

%fit LASSO model
lm_lasso = fitlm(X_lasso(:, selected_vars), Y_lasso);

%metrics
mse_lasso = lm_lasso.MSE;
r2_lasso = lm_lasso.Rsquared.Adjusted;

fprintf('LASSO Model - MSE: %.4f, Adjusted R^2: %.4f\n', mse_lasso, r2_lasso);

% ---- Results Comparison ----
results_table = table({'Full Model'; 'Stepwise Model'; 'LASSO Model'}, ...
                      [mse_full; mse_stepwise; mse_lasso], ...
                      [r2_full; r2_stepwise; r2_lasso], ...
                      'VariableNames', {'Model', 'MSE', 'Adjusted_R2'});

disp('Model Comparison Results:');
disp(results_table);

%---Without variable Spike---
% Remove the Spike variable
indepedent_vars_no_spike = removevars(indepedent_vars, 'Spike');

lm_full_no_spike = fitlm(indepedent_vars(:, {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode'}), EDduration);
lm_stepwise_no_spike = stepwiselm(indepedent_vars(:, {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode'}), EDduration, 'Verbose', 1);

% Preprocess the data for LASSO
X_lasso_no_spike = table2array(indepedent_vars_no_spike);

% Perform LASSO regression with cross-validation
[beta_no_spike, fitinfo_no_spike] = lasso(X_lasso_no_spike, Y_lasso, 'CV', 10);

%metrics no spike
mse_full_no_spike = lm_full_no_spike.MSE;
r2_full_no_spike = lm_full_no_spike.Rsquared.Adjusted;

mse_stepwise_no_spike = lm_stepwise_no_spike.MSE;
r2_stepwise_no_spike = lm_stepwise_no_spike.Rsquared.Adjusted;

selected_vars_no_spike = find(beta_no_spike(:, fitinfo_no_spike.IndexMinMSE) ~= 0);
lm_lasso_no_spike = fitlm(X_lasso_no_spike(:, selected_vars_no_spike), Y_lasso);
mse_lasso_no_spike = lm_lasso_no_spike.MSE;
r2_lasso_no_spike = lm_lasso_no_spike.Rsquared.Adjusted;

lambda_optimal_no_spike = fitinfo_no_spike.LambdaMinMSE;

%comparison table without spike
results_table_no_spike = table({'Full Model'; 'Stepwise Model'; 'LASSO Model'}, ...
                      [mse_full_no_spike; mse_stepwise_no_spike; mse_lasso_no_spike], ...
                      [r2_full_no_spike; r2_stepwise_no_spike; r2_lasso_no_spike], ...
                      'VariableNames', {'Model', 'MSE', 'Adjusted_R2'});
disp('Model Comparison Results without Spike:');
disp(results_table_no_spike);


%Model Comparison Results:
%       Model            MSE      Adjusted_R2
% __________________    ______    ___________

% {'Full Model'    }    62.081      0.040702 
% {'Stepwise Model'}    62.721      0.030815 
% {'LASSO Model'   }    146.44    2.2204e-16 

% Model Comparison Results without Spike:
%           Model            MSE      Adjusted_R2
%     __________________    ______    ___________

%     {'Full Model'    }    110.93      0.24253  
%     {'Stepwise Model'}    83.753      0.42808  
%     {'LASSO Model'   }    110.93      0.24253 
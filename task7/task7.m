%Group40Ex7

% Load the data
current_file_path = mfilename('fullpath');
[parent_folder, ~, ~] = fileparts(fileparts(current_file_path));
data_path = fullfile(parent_folder, 'TMS.xlsx');
if ~exist(data_path, 'file')
    error('The file TMS.xlsx does not exist in the specified path: %s', data_path);
end

% Read data
data = readtable(data_path);
data_with_TMS = data(data.TMS == 1, :);

% === Strategy Based on Task 6 ===
% Decision: Use data WITHOUT Spike based on Task 6 results (better 
% performance without Spike)
% Remove Spike variable
data_with_TMS_NoSpike = removevars(data_with_TMS, 'Spike');

% Ensure all columns are numeric
columns_to_convert = {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode'};
for i = 1:length(columns_to_convert)
    column = columns_to_convert{i};
    if iscell(data_with_TMS.(column))
        data_with_TMS.(column) = cellfun(@(x) str2double(x), data_with_TMS.(column), 'UniformOutput', false);
        data_with_TMS.(column) = cell2mat(data_with_TMS.(column));
    end
end

% Select variables
indepedent_vars = table2array(data_with_TMS(:, {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode'}));
EDduration = data_with_TMS.EDduration;

% Split data into training and testing sets
rng(1); % For reproducibility
cv = cvpartition(height(data_with_TMS), 'HoldOut', 0.3);
train_idx = training(cv);
test_idx = test(cv);

X_train = indepedent_vars(train_idx, :);
Y_train = EDduration(train_idx);
X_test = indepedent_vars(test_idx, :);
Y_test = EDduration(test_idx);

% --- Full Model ---
lm_full = fitlm(X_train, Y_train);
Y_pred_full = predict(lm_full, X_test);
mse_full = mean((Y_test - Y_pred_full).^2);

% --- Stepwise Regression ---
lm_stepwise = stepwiselm(X_train, Y_train);
Y_pred_stepwise = predict(lm_stepwise, X_test);
mse_stepwise = mean((Y_test - Y_pred_stepwise).^2);

% --- LASSO Model ---
[beta, fitinfo] = lasso(X_train, Y_train, 'CV', 10);
lambda_optimal = fitinfo.LambdaMinMSE;
selected_vars = find(beta(:, fitinfo.IndexMinMSE) ~= 0);
X_train_lasso = X_train(:, selected_vars);
X_test_lasso = X_test(:, selected_vars);

lm_lasso = fitlm(X_train_lasso, Y_train);
Y_pred_lasso = predict(lm_lasso, X_test_lasso);
mse_lasso = mean((Y_test - Y_pred_lasso).^2);

% --- Results ---
results_table = table({'Full Model'; 'Stepwise Model'; 'LASSO Model'}, ...
                      [mse_full; mse_stepwise; mse_lasso], ...
                      'VariableNames', {'Model', 'MSE'});

disp('Model Comparison Results (Initial Variable Selection):');
disp(results_table);

% === Model Evaluation with Variable Selection in Training Set ===
% --- Stepwise Model with Training Selection ---
lm_stepwise_train = stepwiselm(X_train, Y_train);
selected_vars_stepwise = find(lm_stepwise_train.Coefficients.pValue(2:end) < 0.05);
X_train_stepwise = X_train(:, selected_vars_stepwise);
X_test_stepwise = X_test(:, selected_vars_stepwise);

lm_stepwise_refit = fitlm(X_train_stepwise, Y_train);
Y_pred_stepwise_refit = predict(lm_stepwise_refit, X_test_stepwise);
mse_stepwise_refit = mean((Y_test - Y_pred_stepwise_refit).^2);

% --- LASSO Model with Training Selection ---
[beta_train, fitinfo_train] = lasso(X_train, Y_train, 'CV', 10);
lambda_optimal_train = fitinfo_train.LambdaMinMSE;
selected_vars_lasso_train = find(beta_train(:, fitinfo_train.IndexMinMSE) ~= 0);
X_train_lasso_train = X_train(:, selected_vars_lasso_train);
X_test_lasso_train = X_test(:, selected_vars_lasso_train);

lm_lasso_refit = fitlm(X_train_lasso_train, Y_train);
Y_pred_lasso_refit = predict(lm_lasso_refit, X_test_lasso_train);
mse_lasso_refit = mean((Y_test - Y_pred_lasso_refit).^2);

% --- Results ---
results_table_refit = table({'Stepwise Model (Refit)'; 'LASSO Model (Refit)'}, ...
                             [mse_stepwise_refit; mse_lasso_refit], ...
                             'VariableNames', {'Model', 'MSE'});

disp('Model Comparison Results (Refit in Training Set):');
disp(results_table_refit);

%Model Comparison Results (Initial Variable Selection):
% Model            MSE  
% __________________    ______

% {'Full Model'    }    207.22
% {'Stepwise Model'}    188.17
% {'LASSO Model'   }    274.55

% %Model Comparison Results (Refit in Training Set):
% Model                MSE  
% __________________________    ______

% {'Stepwise Model (Refit)'}     199.2
% {'LASSO Model (Refit)'   }    208.79

% === Analysis and Conclusions ===
% - Stepwise Model performed best in both initial analysis (MSE = 188.17) and refit (MSE = 199.2).
% - Full Model showed higher error (MSE = 207.22), indicating less effective predictor selection.
% - LASSO Model underperformed in the initial analysis (MSE = 274.55) and refit (MSE = 208.79).
%
% Recommendations:
% - Use Stepwise Model for best balance between accuracy and simplicity.
% - Exclude Spike variable as it improved overall model reliability and accuracy.

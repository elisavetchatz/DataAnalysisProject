% Group40Ex6

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

% Keep only rows with non-missing Spike values
data_with_TMS_Spike = data_with_TMS(~ismissing(data_with_TMS.Spike), :);

% Ensure all columns are numeric for Spike analysis
columns_to_convert = {'Setup', 'Stimuli', 'Intensity', 'Spike', 'Frequency', 'CoilCode'};
for i = 1:length(columns_to_convert)
    column = columns_to_convert{i};
    if iscell(data_with_TMS_Spike.(column))
        data_with_TMS_Spike.(column) = cellfun(@(x) str2double(x), data_with_TMS_Spike.(column), 'UniformOutput', false);
        data_with_TMS_Spike.(column) = cell2mat(data_with_TMS_Spike.(column));
    end
end

% Select variables
indepedent_vars = table2array(data_with_TMS_Spike(:, {'Setup', 'Stimuli', 'Intensity', 'Spike', 'Frequency', 'CoilCode'}));
EDduration = data_with_TMS_Spike.EDduration;

% === Analysis with Spike ===
% --- Full Model ---
lm_full = fitlm(indepedent_vars, EDduration);
mse_full = lm_full.MSE;
r2_full = lm_full.Rsquared.Adjusted;
fprintf('Full Model - MSE: %.4f, Adjusted R^2: %.4f\n', mse_full, r2_full);

% --- Stepwise Regression ---
lm_stepwise = stepwiselm(indepedent_vars, EDduration);
mse_stepwise = lm_stepwise.MSE;
r2_stepwise = lm_stepwise.Rsquared.Adjusted;
fprintf('Stepwise Model - MSE: %.4f, Adjusted R^2: %.4f\n', mse_stepwise, r2_stepwise);

% --- LASSO Model ---
[beta, fitinfo] = lasso(indepedent_vars, EDduration, 'CV', 10);
lambda_optimal = fitinfo.LambdaMinMSE;
selected_vars = find(beta(:, fitinfo.IndexMinMSE) ~= 0);
lm_lasso = fitlm(indepedent_vars(:, selected_vars), EDduration);
mse_lasso = lm_lasso.MSE;
r2_lasso = lm_lasso.Rsquared.Adjusted;
fprintf('LASSO Model - MSE: %.4f, Adjusted R^2: %.4f\n', mse_lasso, r2_lasso);

% Results comparison
results_table = table({'Full Model'; 'Stepwise Model'; 'LASSO Model'}, ...
                      [mse_full; mse_stepwise; mse_lasso], ...
                      [r2_full; r2_stepwise; r2_lasso], ...
                      'VariableNames', {'Model', 'MSE', 'Adjusted_R2'});
disp('Model Comparison Results:');
disp(results_table);

% === Analysis without Spike ===
data_with_TMS_NoSpike = removevars(data_with_TMS, 'Spike');

% Ensure all columns are numeric for no-Spike analysis
columns_to_convert = {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode'};
for i = 1:length(columns_to_convert)
    column = columns_to_convert{i};
    if iscell(data_with_TMS_NoSpike.(column))
        data_with_TMS_NoSpike.(column) = cellfun(@(x) str2double(x), data_with_TMS_NoSpike.(column), 'UniformOutput', false);
        data_with_TMS_NoSpike.(column) = cell2mat(data_with_TMS_NoSpike.(column));
    end
end

% Select independent variables and dependent variable
indepedent_vars_NoSpike = table2array(data_with_TMS_NoSpike(:, {'Setup', 'Stimuli', 'Intensity', 'Frequency', 'CoilCode'}));
EDduration_NoSpike = data_with_TMS_NoSpike.EDduration;

% --- Full Model without Spike ---
lm_full_no_spike = fitlm(indepedent_vars_NoSpike, EDduration_NoSpike);
mse_full_no_spike = lm_full_no_spike.MSE;
r2_full_no_spike = lm_full_no_spike.Rsquared.Adjusted;

% --- Stepwise Regression without Spike ---
lm_stepwise_no_spike = stepwiselm(indepedent_vars_NoSpike, EDduration_NoSpike);
mse_stepwise_no_spike = lm_stepwise_no_spike.MSE;
r2_stepwise_no_spike = lm_stepwise_no_spike.Rsquared.Adjusted;

% --- LASSO Model without Spike ---
[beta_no_spike, fitinfo_no_spike] = lasso(indepedent_vars_NoSpike, EDduration_NoSpike, 'CV', 10);
lambda_optimal_no_spike = fitinfo_no_spike.LambdaMinMSE;
selected_vars_no_spike = find(beta_no_spike(:, fitinfo_no_spike.IndexMinMSE) ~= 0);
lm_lasso_no_spike = fitlm(indepedent_vars_NoSpike(:, selected_vars_no_spike), EDduration_NoSpike);
mse_lasso_no_spike = lm_lasso_no_spike.MSE;
r2_lasso_no_spike = lm_lasso_no_spike.Rsquared.Adjusted;
%disp(lambda_optimal_no_spike);


% Results comparison without Spike
results_table_no_spike = table({'Full Model'; 'Stepwise Model'; 'LASSO Model'}, ...
                               [mse_full_no_spike; mse_stepwise_no_spike; mse_lasso_no_spike], ...
                               [r2_full_no_spike; r2_stepwise_no_spike; r2_lasso_no_spike], ...
                               'VariableNames', {'Model', 'MSE', 'Adjusted_R2'});

disp('Model Comparison Results without Spike:');
disp(results_table_no_spike);



% Model Comparison Results:
%           Model            MSE      Adjusted_R2
%     __________________    ______    ___________

%     {'Full Model'    }    62.081     0.040702  
%     {'Stepwise Model'}    62.364     0.036332  
%     {'LASSO Model'   }    61.422     0.050898    

% Model Comparison Results without Spike:
%           Model            MSE      Adjusted_R2
%     __________________    ______    ___________

%     {'Full Model'    }    110.93      0.24253  
%     {'Stepwise Model'}    83.753      0.42808  
%     {'LASSO Model'   }    110.93      0.24253  

% === Analysis and Conclusions ===
% For the case with TMS, we explored multiple regression models using Setup, Stimuli, Intensity, Spike, 
% Frequency, and CoilCode. 

% --- With Spike ---
% Note: For the analysis with Spike, we used only rows with valid Spike values, reducing the dataset.
% Conclusion: The LASSO model performed best, handling multicollinearity and selecting the most relevant predictors.

% --- Without Spike ---
% Conclusion: The Stepwise Model performed best without Spike, indicating that Spike may introduce noise 
% or redundancy. 

% --- Final Recommendation ---
% - Use the LASSO model with Spike for robust performance.
% - Use the Stepwise Model without Spike for better Adjusted R^2 and error reduction.
% - Proper handling of missing Spike values was essential for reliable analysis.

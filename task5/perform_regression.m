
% Function to perform regression and calculate metrics
function result = perform_regression(data_subset, case_name)
    % Convert Setup to categorical for regression
    data_subset.Setup = categorical(data_subset.Setup);
    
    % Fit linear regression model
    mdl = fitlm(data_subset, 'EDduration ~ Setup');

    % Extract R-squared and adjusted R-squared
    rsquared = mdl.Rsquared.Ordinary;
    adj_rsquared = mdl.Rsquared.Adjusted;

    % Check residuals
    residuals = mdl.Residuals.Raw;
    % Compute basic residual statistics (mean, std) instead of autocorrelation
    mean_residual = mean(residuals);
    std_residual = std(residuals);

    % Store results
    result.Case = string(case_name);  % Ensure compatibility with table creation
    result.Rsquared = rsquared;
    result.AdjustedRsquared = adj_rsquared;
    result.MeanResidual = mean_residual;
    result.StdResidual = std_residual;
end
% Linear analysis
function analyze_linear(data, TMS_value)
    % Filter the data for the specified TMS value
    data_filtered = data(data.TMS == TMS_value, :);
    
    % Extract EDduration and convert Setup to numeric form
    EDduration = data_filtered.EDduration;
    Setup_numeric = double(categorical(data_filtered.Setup));
    
    % Add a column of ones for the intercept in the regression model
    xM = [ones(length(Setup_numeric), 1), Setup_numeric];
    y = EDduration;  % Response variable
    
    % Perform linear regression
    [b, bint, r, ~, stats] = regress(y, xM);
    yhat = b(1) + Setup_numeric * b(2);  % Predicted values
    
    % Calculate and display R-squared
    R2 = stats(1);
    fprintf('Linear Model - R^2 for TMS = %d: %.3f\n', TMS_value, R2);
    
    % Check if Setup is significantly correlated with EDduration
    if bint(2, 1) < 0 && bint(2, 2) > 0
        fprintf('No significant correlation for TMS = %d.\n', TMS_value);
    else
        fprintf('Significant correlation for TMS = %d.\n', TMS_value);
    end
    

    % Standardize the residuals
    r_standardized = r  / std(r);
    
    % Plot standardized residuals
    
    
    % Plot data and fitted regression line
    figure;
    scatter(Setup_numeric, y, 'filled');
    hold on;
    plot(Setup_numeric, yhat, '-r');  % Regression line
    xlabel('Setup (numeric)');
    ylabel(sprintf('EDduration (TMS = %d)', TMS_value));
    title(sprintf('Linear Regression for TMS = %d', TMS_value));
    legend('Data points', 'Fitted line');
    grid on;
    hold off;
    
    % Plot residuals to check model adequacy
    figure;
    plot(r_standardized, 'o');
    hold on;
    yline(2, '--r');
    yline(-2, '--r');
    plot(r_standardized, 'o');
    title(sprintf('Standardized Residuals for Linear Model (TMS = %d)', TMS_value));
    xlabel('Observation');
    ylabel('Standardized Residual');
    grid on;
    hold off;

end
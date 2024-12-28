%Group40Exe2

data = readtable('TMS.xlsx');

% Extract relevant columns for ED duration with different coil codes
ED_coil_one = data.EDduration(strcmp(data.CoilCode, '1'));
ED_coil_zero = data.EDduration(strcmp(data.CoilCode, '0'));

% Remove missing values to be safe 
ED_coil_one = ED_coil_one(~isnan(ED_coil_one));
ED_coil_zero = ED_coil_zero(~isnan(ED_coil_zero));

% Calculate the lambda parameter for the exponential distribution
lambda1 = 1 / mean(ED_coil_one);
lambda2 = 1 / mean(ED_coil_zero);

% Ιστόγραμμα και Q-Q Plot για CoilCode 1, 0
plot_histogram_qq(ED_coil_one, lambda1, 1);
plot_histogram_qq(ED_coil_zero, lambda2, 0);

% Number of resampled datasets
num_resamples = 1000;

%1000 random samples from the exponential distribution for each coil code
chi_squared_resampled_one = resampling_goodness_of_fit(ED_coil_one, lambda1, num_resamples);
chi_squared_resampled_zero = resampling_goodness_of_fit(ED_coil_zero, lambda2, num_resamples);

[h_one, ~, stats] = chi2gof(ED_coil_one, 'CDF', @(x)expcdf(x, 1/lambda1), 'nparams', 1);
chi_squared_original_one = stats.chi2stat;
[h_zero, ~, stats]  = chi2gof(ED_coil_zero, 'CDF', @(x)expcdf(x, 1/lambda2), 'nparams', 1);
chi_squared_original_zero = stats.chi2stat;

% Compare the original and resampled chi-squared statistics
threshold_one = prctile(chi_squared_resampled_one, 95);
threshold_zero = prctile(chi_squared_resampled_zero, 95);


% Determine if the null hypothesis is rejected
if chi_squared_original_one < threshold_one
    % Null hypothesis is not rejected
    acceptance_one_string = 'cannot be rejected';
else
    % Null hypothesis is rejected
    acceptance_one_string = 'can be rejected';
end

if chi_squared_original_zero < threshold_zero
    % Null hypothesis is not rejected
    acceptance_zero_string = 'cannot be rejected';
else
    % Null hypothesis is rejected
    acceptance_zero_string = 'can be rejected';
end

fprintf('Acceptance of hypothesis for Coil Code 1: %s\n', acceptance_one_string);
fprintf('Acceptance of hypothesis for Coil Code 0: %s\n', acceptance_zero_string);

% Compare with parametric control 
[hypothesis_one, ~, ~] = chi2gof(ED_coil_one, 'CDF', @(x)expcdf(x, 1/lambda1), 'nparams', 1, 'Alpha', 0.05);
[hypothesis_zero, ~, ~] = chi2gof(ED_coil_zero, 'CDF', @(x)expcdf(x, 1/lambda2), 'nparams', 1, 'Alpha', 0.05);

fprintf('Acceptance of hypothesis for Coil Code 1 with parametric control: %d\n',  hypothesis_one);
fprintf('Acceptance of hypothesis for Coil Code 0 with parametric control: %d\n', hypothesis_zero);


% --------------------------------
%RESAMPLING
%provides an empirical estimate of how likely the observed Chi-squared 
% statistic is to occur if the data follow an exponential distribution. 
% If the observed Chi-squared value from the actual sample falls in the 
% "right tail" of the Chi-squared distribution generated by the 1000 
% resampled datasets, the null hypothesis of exponential distribution is 
% rejected

% For Coil Code 1: The resampling test accepts the hypothesis that the 
%data follows an exponential distribution (since the result is 1)
% For Coil Code 0: The resampling test accepts the hypothesis that the 
%data follows an exponential distribution (since the result is 1).

% --------------------------------

%PARAMETRIC CONTROL
%directly compares the observed sample to the theoretical exponential 
%distribution and checks if the data come from this distribution.

%For Coil Code 1: The parametric Chi-squared test rejects the hypothesis 
%that the data follows an exponential distribution (since the result is 0)
%For Coil Code 0: The parametric Chi-squared test rejects the hypothesis
%that the data follows an exponential distribution (since the result is 0)

% --------------------------------
%CONCLUSION
%The resampling test suggests that the data could follow an exponential 
% distribution, while the parametric Chi-squared test rejects this 
% hypothesis, indicating potential deviations from the exponential model.
%ΤhIs difference between the two tests is because resampling is more 
% flexible and can handle data variations, while the parametric
% Chi-squared test is stricter and requires the data to fit the 
% exponential distribution more closely.

%PLOTS
%   The histogram for Coil Code 1 closely matches the exponential distribution. 
%Similarly, the Q-Q plot indicates that the data for Coil Code 1 follows the 
%exponential distribution, supporting the intial hypothesis. 
%   For Coil Code 0, the data do not show a similar trend, as the deviation from 
% the diagonal in the Q-Q plot is larger, suggesting a less accurate fit.

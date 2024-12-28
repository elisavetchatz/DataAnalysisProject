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

% Number of resampled datasets
num_resamples = 1000;

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

% Determine if the null hypothesis is rejected
if hypothesis_zero == 0
    % Null hypothesis is not rejected
    acceptance_zero_string = 'cannot be rejected';
else
    % Null hypothesis is rejected
    acceptance_zero_string = 'can be rejected';
end

if hypothesis_one == 0
    % Null hypothesis is not rejected
    acceptance_one_string = 'cannot be rejected';
else
    % Null hypothesis is rejected
    acceptance_one_string = 'can be rejected';
end
fprintf('Acceptance of hypothesis for Coil Code 1 with parametric control: %s\n',  acceptance_one_string);
fprintf('Acceptance of hypothesis for Coil Code 0 with parametric control: %s\n', acceptance_zero_string);




%%% Sxolia
% --------------------------------
% Kai me tous duo tropous pou exetazoume to an i katanomi einai ekthetiki
% mporoume na dextoume oti einai ekthetiki

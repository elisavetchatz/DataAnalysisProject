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

chi_squared_original_one = chi2gof(ED_coil_one, 'CDF', @(x)expcdf(x, 1/lambda1), 'nparams', 1);
chi_squared_original_zero = chi2gof(ED_coil_zero, 'CDF', @(x)expcdf(x, 1/lambda2), 'nparams', 1);

% Compare the original and resampled chi-squared statistics
threshold_one = prctile(chi_squared_resampled_one, 95);
threshold_zero = prctile(chi_squared_resampled_zero, 95);

accepted_one = chi_squared_original_one < threshold_one;
accepted_zero = chi_squared_original_zero < threshold_zero;

fprintf('Acceptance of hypothesis for Coil Code 1: %d\n', accepted_one);
fprintf('Acceptance of hypothesis for Coil Code 0: %d\n', accepted_zero);

% Compare with parametric control 
[hypothesis_one, ~, ~] = chi2gof(ED_coil_one, 'CDF', @(x)expcdf(x, 1/lambda1), 'nparams', 1, 'Alpha', 0.05);
[hypothesis_zero, ~, ~] = chi2gof(ED_coil_zero, 'CDF', @(x)expcdf(x, 1/lambda2), 'nparams', 1, 'Alpha', 0.05);

fprintf('Acceptance of hypothesis for Coil Code 1 with parametric control: %d\n',  hypothesis_one);
fprintf('Acceptance of hypothesis for Coil Code 0 with parametric control: %d\n', hypothesis_zero);




%%% Sxolia
% --------------------------------
% Me to resampling dexomaste oti ta data mporei na einai apo ekthetiki katanomi
% Alla me thn parametriko elegxo, den to dexomaste 
% Load the data from TMS.xlsx
data = readtable('TMS.xlsx');

% Extract relevant columns for ED duration with and without TMS
ED_with_TMS = data.EDduration(data.TMS == 1);   % Replace with the actual column name
ED_without_TMS = data.EDduration(data.TMS == 0); % Replace with the actual column name

% Remove missing values
ED_with_TMS = ED_with_TMS(~isnan(ED_with_TMS));
ED_without_TMS = ED_without_TMS(~isnan(ED_without_TMS));


% List of distributions to test
dist_names = {'Normal', 'Exponential', 'Lognormal', 'Weibull', 'Gamma'};
% Perform goodness of fit test for ED duration with TMS
test_goodness_of_fit(ED_with_TMS, dist_names);
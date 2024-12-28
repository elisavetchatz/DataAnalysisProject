%Group40Exe1

data = readtable('TMS.xlsx');

% Extract relevant columns for ED duration with and without TMS
ED_with_TMS = data.EDduration(data.TMS == 1);
ED_without_TMS = data.EDduration(data.TMS == 0);

% Remove missing values to be safe 
ED_with_TMS = ED_with_TMS(~isnan(ED_with_TMS));
ED_without_TMS = ED_without_TMS(~isnan(ED_without_TMS));


% List of distributions to test
dist_names = {'BirnbaumSaunders', 'Burr', 'Exponential', 'Extreme Value', 'Gamma', 'Generalized Extreme Value', 'Generalized Pareto', 'Half Normal', 'InverseGaussian', 'Logistic', 'Loglogistic', 'Lognormal', 'Nakagami', 'Normal', 'Poisson', 'Rayleigh', 'Rician', 'tLocationScale', 'Weibull'};

warning('off', 'all'); % Suppress warnings for better output readability
% Perform goodness of fit test for ED duration with TMS
[best_fit_with, ~, ~] = test_goodness_of_fit(ED_with_TMS, dist_names);
[best_fit_without, ~, ~] = test_goodness_of_fit(ED_without_TMS, dist_names);


num_bins = ceil(sqrt(length(ED_with_TMS))); % Number of bins (rule of thumb)
bin_edges = linspace(min([ED_with_TMS; ED_without_TMS]), max([ED_with_TMS; ED_without_TMS]), num_bins);


ED_with_TMS_struct = struct('data', ED_with_TMS, 'dataname', 'ED with TMS', 'color', 'r');
ED_without_TMS_struct = struct('data', ED_without_TMS, 'dataname', 'ED without TMS', 'color', 'b');

plot_with_best_fit(ED_with_TMS_struct, bin_edges, best_fit_with);
plot_with_best_fit(ED_without_TMS_struct, bin_edges, best_fit_without);

xlabel('Time(s)');
ylabel('Probability Density');
title('Histogram and Best Fit Distribution for ED Duration');


legend('show')
hold off;



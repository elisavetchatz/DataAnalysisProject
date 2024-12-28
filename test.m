% Group40Exe1

% Load the data from TMS.xlsx
data = readtable('TMS.xlsx');

% Extract relevant columns for ED duration with and without TMS
ED_with_TMS = data.EDduration(data.TMS == 1);
ED_without_TMS = data.EDduration(data.TMS == 0);

% Remove missing values to be safe 
ED_with_TMS = ED_with_TMS(~isnan(ED_with_TMS));
ED_without_TMS = ED_without_TMS(~isnan(ED_without_TMS));


% List of distributions to test
dist_names = {'BirnbaumSaunders', 'Burr', 'Exponential', 'Extreme Value', 'Gamma', 'Generalized Extreme Value', 'Generalized Pareto', 'Half Normal', 'InverseGaussian', 'Kernel', 'Logistic', 'Loglogistic', 'Lognormal', 'Nakagami', 'Normal', 'Poisson', 'Rayleigh', 'Rician', 'tLocationScale', 'Weibull'};

warning('off', 'all'); % Suppress warnings for better output readability
% Perform goodness of fit test for ED duration with TMS
[best_fit_with, ~, ~] = test_goodness_of_fit(ED_with_TMS, dist_names);
[best_fit_without, ~, ~] = test_goodness_of_fit(ED_without_TMS, dist_names);


num_bins = ceil(sqrt(length(ED_with_TMS))); % Number of bins (rule of thumb)
bin_edges = linspace(min([ED_with_TMS; ED_without_TMS]), max([ED_with_TMS; ED_without_TMS]), num_bins);
% Display histogram of the data and the best fit distribution
figure;
% Empirical PDFs for ED duration with and without TMS
histogram(ED_with_TMS, Normalization='pdf', BinEdges=bin_edges);
hold on;
histogram(ED_without_TMS, Normalization='pdf', BinEdges=bin_edges);
% Display the best fit distribution for ED duration with and without TMS
plot(bin_edges, pdf(best_fit_with, bin_edges), 'r', 'LineWidth', 1.5);
plot(bin_edges, pdf(best_fit_without, bin_edges), 'b', 'LineWidth', 1.5);
legend('ED with TMS', 'ED without TMS', 'Best fit with TMS', 'Best fit without TMS');
hold off;
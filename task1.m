%Group40Exe1

data = readtable('TMS.xlsx');  

% Seperate  EDduration Data based on TMS usage
% Elements of EDduration column where the corresponding TMS column is 1
ed_with_tms = data.EDduration(data.TMS == 1);  
% Elements of EDduration column where the corresponding TMS column is 0
ed_without_tms = data.EDduration(data.TMS == 0); 

% Histograms for Empirical PDFs for EDduration with and without TMS
figure;
histogram(ed_with_tms, 'Normalization', 'pdf', 'FaceAlpha', 0.5, 'DisplayName', 'With TMS');
hold on;
histogram(ed_without_tms, 'Normalization', 'pdf', 'FaceAlpha', 0.5, 'DisplayName', 'Without TMS');
title('Empirical PDFs for EDduration with and without TMS');
xlabel('EDduration (seconds)');
ylabel('Probability Density');
legend('show');

% Fit a different type of probability distribution to the ed_without_tms dataset
% This is useful for determining which distribution best describes the data.
dist_without_tms_normal = fitdist(ed_without_tms, 'Normal');  
dist_without_tms_exp = fitdist(ed_without_tms, 'Exponential');  
dist_without_tms_gamma = fitdist(ed_without_tms, 'Gamma');
dist_without_tms_lognormal = fitdist(ed_without_tms, 'Lognormal'); 
dist_without_tms_invgauss = fitdist(ed_without_tms, 'InverseGaussian'); 

% Fit a different type of probability distribution to the ed_with_tms dataset
% This is useful for determining which distribution best describes the data.
dist_with_tms_normal = fitdist(ed_with_tms, 'Normal');  
dist_with_tms_exp = fitdist(ed_with_tms, 'Exponential');  
dist_with_tms_gamma = fitdist(ed_with_tms, 'Gamma');
dist_with_tms_lognormal = fitdist(ed_with_tms, 'Lognormal'); 
dist_with_tms_invgauss = fitdist(ed_with_tms, 'InverseGaussian'); 

% Plot for without TMS, fitting candidate distributions
figure;
histogram(ed_without_tms, 'Normalization', 'pdf', 'BinWidth', 0.5, 'FaceAlpha', 0.6);
hold on;
x = 0:0.1:max(ed_without_tms);
plot(x, pdf(dist_without_tms_normal, x), 'r-', 'LineWidth', 1.5); % Normal
plot(x, pdf(dist_without_tms_exp, x), 'b--', 'LineWidth', 1.5); % Exponential
plot(x, pdf(dist_without_tms_gamma, x), 'g-.', 'LineWidth', 1.5); % Gamma
plot(x, pdf(dist_without_tms_lognormal, x), 'm:', 'LineWidth', 1.5); % Log-Normal
plot(x, pdf(dist_without_tms_invgauss, x), 'k-', 'LineWidth', 1.5); % Inverse Gaussian
legend('Empirical', 'Normal', 'Exponential', 'Gamma', 'Log-Normal', 'Inverse Gaussian');
title('Distribution Fit for Without TMS Data');

% Plot for with TMS, fitting candidate distributions
figure;
histogram(ed_without_tms, 'Normalization', 'pdf', 'BinWidth', 0.5, 'FaceAlpha', 0.6);
hold on;
x = 0:0.1:max(ed_with_tms);
plot(x, pdf(dist_with_tms_normal, x), 'r-', 'LineWidth', 1.5); % Normal
plot(x, pdf(dist_with_tms_exp, x), 'b--', 'LineWidth', 1.5); % Exponential
plot(x, pdf(dist_with_tms_gamma, x), 'g-.', 'LineWidth', 1.5); % Gamma
plot(x, pdf(dist_with_tms_lognormal, x), 'm:', 'LineWidth', 1.5); % Log-Normal
plot(x, pdf(dist_with_tms_invgauss, x), 'k-', 'LineWidth', 1.5); % Inverse Gaussian
legend('Empirical', 'Normal', 'Exponential', 'Gamma', 'Log-Normal', 'Inverse Gaussian');
title('Distribution Fit for With TMS Data');

% Now, we choose the best distribution for each case according to the diagrams: 
% Inverse Gaussian for both with and without TMS
% Then, we perform a chi-square test to check the goodness of fit of the chosen distribution

%Calculate Expected Values for each distribution
% Calculate bin edges for grouping data into intervals
bin_edges = linspace(min([ed_with_tms; ed_without_tms]), max([ed_with_tms; ed_without_tms]), 10);
% Observed frequencies for each bin
observed_without = histcounts(ed_without_tms, bin_edges);
observed_with = histcounts(ed_with_tms, bin_edges);

% Expected frequencies for each bin
expected_without_invgauss = diff(cdf(dist_without_tms_invgauss, bin_edges))*length(ed_without_tms);
expected_with_invgauss = diff(cdf(dist_with_tms_invgauss, bin_edges))*length(ed_with_tms);    

% Check the goodness of fit of the normal, exponential and gamma distributions
% Chi-Square Statistics for each distribution for both with and without TMS
chi2_without = sum((observed_without - expected_without_invgauss).^2 ./ expected_without_invgauss);
df_without = length(observed_without) - 2; % degrees of freedom
p_without = 1 - chi2cdf(chi2_without, df_without); % p-value

chi2_with = sum((observed_with - expected_with_invgauss).^2 ./ expected_with_invgauss);
df_with = length(observed_with) - 2; % degrees of freedom
p_with = 1 - chi2cdf(chi2_with, df_with); % p-value 

% Print the results
fprintf('Chi-Square Test for Without TMS Data:\n');
fprintf('Chi-Square Statistic: %.4f\n', chi2_without);
fprintf('Degrees of Freedom: %d\n', df_without);
fprintf('p-value: %.4f\n', p_without);

fprintf('Chi-Square Test for With TMS Data:\n');
fprintf('Chi-Square Statistic: %.4f\n', chi2_with);
fprintf('Degrees of Freedom: %d\n', df_with);
fprintf('p-value: %.4f\n', p_with);

% Determine the fit based on p-value
fit_without = "Good Fit";
if p_without <= 0.05
    fit_without = "Not a Good Fit";
end

fit_with = "Good Fit";
if p_with <= 0.05
    fit_with = "Not a Good Fit";
end

% Prepare the data for uitable
bin_labels = strcat('Bin ', string(1:length(observed_without))); % Create bin labels
printable_data = {
    'Without TMS', chi2_without, df_without, p_without, char(mat2str(observed_without)), char(mat2str(round(expected_without_invgauss, 1))), char(fit_without);
    'With TMS', chi2_with, df_with, p_with, char(mat2str(observed_with)), char(mat2str(round(expected_with_invgauss, 1))), char(fit_with)
};
columnNames = {'Condition', 'Chi-Square Statistic', 'Degrees of Freedom', 'p-value', 'Observed Frequencies', 'Expected Frequencies', 'Fit'};
figure('Name', 'Chi-Square Test Results', 'NumberTitle', 'off');
uitable('Data', printable_data, ...
        'ColumnName', columnNames, ...
        'RowName', [], ...
        'Position', [20 20 1500 150]);


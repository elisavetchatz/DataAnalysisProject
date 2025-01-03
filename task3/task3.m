% Read the data from the file
current_file_path = mfilename('fullpath');
[parent_folder, ~, ~] = fileparts(fileparts(current_file_path));
data_path = fullfile(parent_folder, 'TMS.xlsx');
data = readtable(data_path);  

% Extract ED duration data for both TMS and no TMS
ED_without_TMS = data.EDduration(data.TMS == 0);
ED_with_TMS = data.EDduration(data.TMS == 1);

% Calculate the mean ED duration for both cases (without TMS and with TMS)
mean_ED_without_TMS = mean(ED_without_TMS);
mean_ED_with_TMS = mean(ED_with_TMS);

% Split the data into 6 samples based on the Setup variable
ED_without_TMS_samples = cell(1, 6);
ED_with_TMS_samples = cell(1, 6);

% Loop through all 6 setups and extract the ED durations for both cases
for i = 1:6
    ED_without_TMS_samples{i} = data.EDduration(data.TMS == 0 & data.Setup == i);
    ED_with_TMS_samples{i} = data.EDduration(data.TMS == 1 & data.Setup == i);
end

% Fit a normal distribution to the ED duration data (without TMS)
pd_without_TMS = fitdist(ED_without_TMS, 'Normal');
mu_without_TMS = pd_without_TMS.mu;
sigma_without_TMS = pd_without_TMS.sigma;

% Fit a normal distribution to the ED duration data (with TMS)
pd_with_TMS = fitdist(ED_with_TMS, 'Normal');
mu_with_TMS = pd_with_TMS.mu;
sigma_with_TMS = pd_with_TMS.sigma;

% Perform a Chi-square goodness-of-fit test for normal distribution for each setup
p_values_without_TMS = zeros(1, 6); % Array to store p-values for "No TMS"
p_values_with_TMS = zeros(1, 6); % Array to store p-values for "With TMS"

% Bootstrap resampling for ED durations (without and with TMS)
num_resamples = 1000;
bootstrap_means_without_TMS = zeros(num_resamples, 6);
bootstrap_means_with_TMS = zeros(num_resamples, 6);

% Confidence intervals for ED durations (without TMS and with TMS)
ci_without_TMS = cell(1, 6);
ci_with_TMS = cell(1, 6);

for setup_num = 1:6
    % Test for normality in each setup (without TMS)
    norm_cdf_without_TMS = @(x) normcdf(x, mu_without_TMS, sigma_without_TMS);
    [hypothesis_without_TMS, p_values_without_TMS(setup_num)] = chi2gof(ED_without_TMS_samples{setup_num}, 'CDF', norm_cdf_without_TMS, 'Alpha', 0.05);

    % Test for normality in each setup (with TMS)
    norm_cdf_with_TMS = @(x) normcdf(x, mu_with_TMS, sigma_with_TMS);
    [hypothesis_with_TMS, p_values_with_TMS(setup_num)] = chi2gof(ED_with_TMS_samples{setup_num}, 'CDF', norm_cdf_with_TMS, 'Alpha', 0.05);

    % If the data is not normally distributed, perform bootstrap resampling
    if hypothesis_without_TMS == 1
        % Bootstrap for ED without TMS
        for i = 1:num_resamples
            bootstrap_means_without_TMS(i, setup_num) = mean(datasample(ED_without_TMS_samples{setup_num}, length(ED_without_TMS_samples{setup_num})));
        end
        % Confidence intervals for ED without TMS
        ci_without_TMS{setup_num} = prctile(bootstrap_means_without_TMS(:, setup_num), [0.025, 0.975]);

    else
        % If the data is normally distributed, calculate the confidence intervals directly
        ci_without_TMS{setup_num} = norminv([0.025, 0.975], mu_without_TMS, sigma_without_TMS);
    end
    
    % If the data is not normally distributed, perform bootstrap resampling
    if hypothesis_with_TMS == 1
        % Bootstrap for ED with TMS
        for i = 1:num_resamples
            bootstrap_means_with_TMS(i, setup_num) = mean(datasample(ED_with_TMS_samples{setup_num}, length(ED_with_TMS_samples{setup_num})));
        end
        % Confidence intervals for ED with TMS
        ci_with_TMS{setup_num} = prctile(bootstrap_means_with_TMS(:, setup_num), [0.025, 0.975]);

    else
        % If the data is normally distributed, calculate the confidence intervals directly
        ci_with_TMS{setup_num} = norminv([0.025, 0.975], mu_with_TMS, sigma_with_TMS);
    end 

end

% Plot the Chi-square Goodness-of-Fit Test p-values for both "Without TMS" and "With TMS"
figure;
bar([p_values_without_TMS; p_values_with_TMS]', 'grouped');
title('Chi-square Goodness-of-Fit Test p-values');
set(gca, 'xticklabel', {'Setup 1', 'Setup 2', 'Setup 3', 'Setup 4', 'Setup 5', 'Setup 6'});
ylabel('p-value');
ylim([0 1]);
legend({'No TMS', 'With TMS'});

% -------------------- Plotting --------------------

% 1. Histograms for ED durations (with and without TMS)
figure;
subplot(2, 2, 1);
histogram(ED_without_TMS, 'Normalization', 'pdf');
hold on;
x = linspace(min(ED_without_TMS), max(ED_without_TMS), 100);
plot(x, normpdf(x, mu_without_TMS, sigma_without_TMS), 'r', 'LineWidth', 2);
title('ED Duration without TMS');
xlabel('Duration (seconds)');
ylabel('Probability Density');
legend('Data', 'Normal Fit');

subplot(2, 2, 2);
histogram(ED_with_TMS, 'Normalization', 'pdf');
hold on;
plot(x, normpdf(x, mu_with_TMS, sigma_with_TMS), 'r', 'LineWidth', 2);
title('ED Duration with TMS');
xlabel('Duration (seconds)');
ylabel('Probability Density');
legend('Data', 'Normal Fit');

% 2. Bootstrap Resampling Results for Confidence Intervals
subplot(2, 2, 3);
boxplot(bootstrap_means_without_TMS, 'Labels', {'Setup 1', 'Setup 2', 'Setup 3', 'Setup 4', 'Setup 5', 'Setup 6'});
title('Bootstrap Means (No TMS)');
ylabel('Mean ED Duration');
xlabel('Setup');

subplot(2, 2, 4);
boxplot(bootstrap_means_with_TMS, 'Labels', {'Setup 1', 'Setup 2', 'Setup 3', 'Setup 4', 'Setup 5', 'Setup 6'});
title('Bootstrap Means (With TMS)');
ylabel('Mean ED Duration');
xlabel('Setup');

% -------------------- Conclusion --------------------

% Mathematical Analysis and Discussion:
% - Histograms show the distribution of ED durations, with overlaid normal distribution curves.
% - The bootstrap resampling results show the variability in the means of ED durations across the setups.
% - The Chi-square p-values provide insight into how well the data fits a normal distribution.
%   If the p-value is below the threshold (0.05), we reject the hypothesis that the data follows a normal distribution.
% - From the boxplots, we can see the spread of the bootstrap means for each setup and determine whether the presence of TMS
%   affects the variability in ED durations.

% Based on the statistical tests:
% - The Chi-square test may indicate that the distribution of ED durations is not perfectly normal for both with and without TMS,
%   leading us to use bootstrap for confidence intervals.
% - The confidence intervals provide an estimate of the uncertainty around the mean ED duration for each setup.

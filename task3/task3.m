% Group40Exe3

% Read the data from the file
current_file_path = mfilename('fullpath');
[parent_folder, ~, ~] = fileparts(fileparts(current_file_path));
data_path = fullfile(parent_folder, 'TMS.xlsx');
if ~exist(data_path, 'file')
    error('The file TMS.xlsx does not exist in the specified path: %s', data_path);
end
data = readtable(data_path);  

% Extract ED duration data for both TMS and no TMS
ED_without_TMS = data.EDduration(data.TMS == 0);
ED_with_TMS = data.EDduration(data.TMS == 1);

% Calculate the mean ED duration for both cases (without TMS and with TMS)
mu_without_TMS = mean(ED_without_TMS);
mu_with_TMS = mean(ED_with_TMS);
sigma_without_TMS = std(ED_without_TMS);
sigma_with_TMS = std(ED_with_TMS);

num_resamples = 1000;

% Without TMS
[ci_without_TMS, bootstrap_means_without_TMS, p_values_without_TMS] = calculate_confidence_intervals(data, num_resamples, sigma_without_TMS, mu_without_TMS);

% With TMS
[ci_with_TMS, bootstrap_means_with_TMS, p_values_with_TMS] = calculate_confidence_intervals(data, num_resamples, sigma_with_TMS, mu_with_TMS);

results_table = table('Size', [6, 4], 'VariableTypes', {'cell', 'string', 'cell', 'string'}, 'VariableNames', {'CI_Without_TMS', 'Accepted_Without_TMS', 'CI_With_TMS', 'Accepted_With_TMS'});

% Setup the results table
for setup_num=1:6
    % Populate the table with the confidence intervals and acceptance status
    results_table.CI_Without_TMS{setup_num} = ci_without_TMS{setup_num};
    results_table.CI_With_TMS{setup_num} = ci_with_TMS{setup_num};

    % Check if the mean ED duration is within the confidence intervals
    if mu_without_TMS >= ci_without_TMS{setup_num}(1) && mu_without_TMS <= ci_without_TMS{setup_num}(2)
        results_table.Accepted_Without_TMS(setup_num) = "Yes";
    else
        results_table.Accepted_Without_TMS(setup_num) = "No";
    end
    
    if mu_with_TMS >= ci_with_TMS{setup_num}(1) && mu_with_TMS <= ci_with_TMS{setup_num}(2)
        results_table.Accepted_With_TMS(setup_num) = "Yes";
    else
        results_table.Accepted_With_TMS(setup_num) = "No";
    end
    
end

% Display the table with the results
fprintf('Mean ED Duration without TMS: %.2f seconds\n', mu_without_TMS);
fprintf('Mean ED Duration with TMS: %.2f seconds\n', mu_with_TMS);
disp(results_table);


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

% The results are the following:
% Mean ED Duration without TMS: 13.26 seconds
% Mean ED Duration with TMS: 12.19 seconds
%       CI_Without_TMS       Accepted_Without_TMS        CI_With_TMS         Accepted_With_TMS
%     ___________________    ____________________    ____________________    _________________

%     {[ 8.2280 20.7770]}           "Yes"            {[-11.5235 35.9127]}          "Yes"      
%     {[ 9.7500 14.5714]}           "Yes"            {[  9.6786 14.7143]}          "Yes"      
%     {[19.8889 38.7222]}           "No"             {[ 20.5000 38.7778]}          "No"       
%     {[ 7.0733 11.0858]}           "No"             {[  7.0727 11.1472]}          "No"       
%     {[  4.3136 9.1409]}           "No"             {[   4.2864 8.9364]}          "No"       
%     {[     33 91.5000]}           "No"             {[      33 94.2500]}          "No"       


% We observe that for both with and without TMS, the mean ED duration falls outside the confidence intervals for all setups, except for Setup 1 and 2.

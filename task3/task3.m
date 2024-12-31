data = readtable('TMS.xlsx');

% Extract relevant columns for ED duration with and without TMS
ED_without_TMS = data.EDduration(data.TMS == 0);
ED_with_TMS = data.EDduration(data.TMS == 1);

% Consider this the mo value
mean_ED_without_TMS = mean(ED_without_TMS);
mean_ED_with_TMS = mean(ED_with_TMS);

% Divide into 6 samples depending on the setup value
ED_without_TMS_1 = data.EDduration(data.TMS == 0 & data.Setup == 1);
ED_without_TMS_2 = data.EDduration(data.TMS == 0 & data.Setup == 2);
ED_without_TMS_3 = data.EDduration(data.TMS == 0 & data.Setup == 3);
ED_without_TMS_4 = data.EDduration(data.TMS == 0 & data.Setup == 4);
ED_without_TMS_5 = data.EDduration(data.TMS == 0 & data.Setup == 5);
ED_without_TMS_6 = data.EDduration(data.TMS == 0 & data.Setup == 6);

ED_with_TMS_1 = data.EDduration(data.TMS == 1 & data.Setup == 1);
ED_with_TMS_2 = data.EDduration(data.TMS == 1 & data.Setup == 2);
ED_with_TMS_3 = data.EDduration(data.TMS == 1 & data.Setup == 3);
ED_with_TMS_4 = data.EDduration(data.TMS == 1 & data.Setup == 4);
ED_with_TMS_5 = data.EDduration(data.TMS == 1 & data.Setup == 5);
ED_with_TMS_6 = data.EDduration(data.TMS == 1 & data.Setup == 6);


% Evaluate whether distribution is normal
% Fit a normal distribution to the data
pd_without_TMS = fitdist(ED_without_TMS, 'Normal');
mu_without_TMS = pd_without_TMS.mu;
sigma_without_TMS = pd_without_TMS.sigma;
norm_cdf_without_TMS = @(x) normcdf(x, mu_without_TMS, sigma_without_TMS);
[hypothesis_without_TMS, p_without_TMS] = chi2gof(ED_without_TMS, 'CDF', norm_cdf_without_TMS, 'Alpha', 0.05);

pd_with_TMS = fitdist(ED_with_TMS, 'Normal');
mu_with_TMS = pd_with_TMS.mu;
sigma_with_TMS = pd_with_TMS.sigma;
norm_cdf_with_TMS = @(x) normcdf(x, mu_with_TMS, sigma_with_TMS);
[hypothesis_with_TMS, p_with_TMS] = chi2gof(ED_with_TMS, 'CDF', norm_cdf_with_TMS, 'Alpha', 0.05);


% Perform goodness of fit test for ED duration with TMS
% If the distribution is not normal, use bootstrap
if hypothesis_without_TMS == 1
    hypothesis_string_without = 'can be rejected';
    
    % Bootstrap for ED without TMS
    num_resamples = 1000;
    bootstrap_means_without_TMS = zeros(num_resamples, 6);
    for i = 1:num_resamples
        bootstrap_means_without_TMS(i, 1) = mean(datasample(ED_without_TMS_1, length(ED_without_TMS_1)));
        bootstrap_means_without_TMS(i, 2) = mean(datasample(ED_without_TMS_2, length(ED_without_TMS_2)));
        bootstrap_means_without_TMS(i, 3) = mean(datasample(ED_without_TMS_3, length(ED_without_TMS_3)));
        bootstrap_means_without_TMS(i, 4) = mean(datasample(ED_without_TMS_4, length(ED_without_TMS_4)));
        bootstrap_means_without_TMS(i, 5) = mean(datasample(ED_without_TMS_5, length(ED_without_TMS_5)));
        bootstrap_means_without_TMS(i, 6) = mean(datasample(ED_without_TMS_6, length(ED_without_TMS_6)));
    end
    % Confidence intervals for ED without TMS
    ci_without_TMS_1 = prctile(bootstrap_means_without_TMS(:, 1), [2.5, 97.5]);
    ci_without_TMS_2 = prctile(bootstrap_means_without_TMS(:, 2), [2.5, 97.5]);
    ci_without_TMS_3 = prctile(bootstrap_means_without_TMS(:, 3), [2.5, 97.5]);
    ci_without_TMS_4 = prctile(bootstrap_means_without_TMS(:, 4), [2.5, 97.5]);
    ci_without_TMS_5 = prctile(bootstrap_means_without_TMS(:, 5), [2.5, 97.5]);
    ci_without_TMS_6 = prctile(bootstrap_means_without_TMS(:, 6), [2.5, 97.5]);
else
        hypothesis_string_without = 'cannot be rejected';
end

if hypothesis_with_TMS == 1
    hypothesis_string_with = 'can be rejected';
    
    % Bootstrap for ED with TMS
    num_resamples = 1000;
    bootstrap_means_with_TMS = zeros(num_resamples, 6);
    for i = 1:num_resamples
        bootstrap_means_with_TMS(i, 1) = mean(datasample(ED_with_TMS_1, length(ED_with_TMS_1)));
        bootstrap_means_with_TMS(i, 2) = mean(datasample(ED_with_TMS_2, length(ED_with_TMS_2)));
        bootstrap_means_with_TMS(i, 3) = mean(datasample(ED_with_TMS_3, length(ED_with_TMS_3)));
        bootstrap_means_with_TMS(i, 4) = mean(datasample(ED_with_TMS_4, length(ED_with_TMS_4)));
        bootstrap_means_with_TMS(i, 5) = mean(datasample(ED_with_TMS_5, length(ED_with_TMS_5)));
        bootstrap_means_with_TMS(i, 6) = mean(datasample(ED_with_TMS_6, length(ED_with_TMS_6)));
    end
    % Confidence intervals for ED with TMS
    ci_with_TMS_1 = prctile(bootstrap_means_with_TMS(:, 1), [2.5, 97.5]);
    ci_with_TMS_2 = prctile(bootstrap_means_with_TMS(:, 2), [2.5, 97.5]);
    ci_with_TMS_3 = prctile(bootstrap_means_with_TMS(:, 3), [2.5, 97.5]);
    ci_with_TMS_4 = prctile(bootstrap_means_with_TMS(:, 4), [2.5, 97.5]);
    ci_with_TMS_5 = prctile(bootstrap_means_with_TMS(:, 5), [2.5, 97.5]);
    ci_with_TMS_6 = prctile(bootstrap_means_with_TMS(:, 6), [2.5, 97.5]);
else
        hypothesis_string_with = 'cannot be rejected';
end 

fprintf('p value for ED without TMS: %f\n', p_without_TMS);
fprintf('p value for ED with TMS: %f\n', p_with_TMS);
fprintf('The distribution of ED without TMS is normal: %s\n', hypothesis_string_without);
fprintf('The distribution of ED with TMS is normal: %s\n', hypothesis_string_with);

% Result Table
results = {'Setup 1', ci_without_TMS_1(1), ci_without_TMS_1(2), ci_with_TMS_1(1), ci_with_TMS_1(2); 
           'Setup 2', ci_without_TMS_2(1), ci_without_TMS_2(2), ci_with_TMS_2(1), ci_with_TMS_2(2); 
           'Setup 3', ci_without_TMS_3(1), ci_without_TMS_3(2), ci_with_TMS_3(1), ci_with_TMS_3(2); 
           'Setup 4', ci_without_TMS_4(1), ci_without_TMS_4(2), ci_with_TMS_4(1), ci_with_TMS_4(2); 
           'Setup 5', ci_without_TMS_5(1), ci_without_TMS_5(2), ci_with_TMS_5(1), ci_with_TMS_5(2); 
           'Setup 6', ci_without_TMS_6(1), ci_without_TMS_6(2), ci_with_TMS_6(1), ci_with_TMS_6(2)};
       
f = figure('Name', 'Bootstrap Confidence Intervals', 'NumberTitle', 'off', ...
           'Position', [100, 100, 600, 300]);
t = uitable(f, ...
            'Data', results, ...
            'ColumnName', {'Setup', 'Lower CI (No TMS)', 'Upper CI (No TMS)', 'Lower CI (With TMS)', 'Upper CI (With TMS)'}, ...
            'Position', [25, 50, 550, 200], ...
            'ColumnWidth', {70, 100, 100, 100, 100});
disp('Results displayed in uitable');


% Normal distribution is not a good fit so we will try with bootstrap


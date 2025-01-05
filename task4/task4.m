%Group40Exe4

file_path = 'C:\Users\chatz\DataAnalysisProject\TMS.xlsx';
setup_numbers = 1:6;
alpha = 0.05;

% Read the data from the specified file
data = readtable(file_path);

% Extracting the data from the table
preTMS = data.preTMS(data.Setup == setup_num);
postTMS = data.postTMS(data.Setup == setup_num);

preTMS = preTMS(~isnan(preTMS));
postTMS = postTMS(~isnan(postTMS));

fprintf('Size of preTMS: %d\n', length(preTMS)); % 8
fprintf('Size of postTMS: %d\n', length(postTMS)); % 8


%Test correlation for each setup number (parametric test)
fprintf('Parametric Test Results:\n');
for setup_num = setup_numbers
    check_corr(preTMS, postTMS, alpha);
end

% Test correlation using randomization test
num_random_samples = 1000;
r_true = zeros(length(setup_numbers), 1);
results = struct('r', zeros(num_random_samples, 1), 'p', zeros(num_random_samples, 1));

% Extract results for each setup number
for i = 1:length(setup_numbers)
    r_true(i) = corr(preTMS, postTMS, 'Type', 'Pearson');
    results(i) = randomization(num_random_samples, preTMS, postTMS);

    % Plot histogram of r values
    figure;
    histogram(results(i).r, 'NumBins', round(sqrt(num_random_samples)));
    title(sprintf('Randomization Test Results for Setup %d', setup_numbers(i)));
    hold on;
    y_limits = ylim;
    plot([r_true(i), r_true(i)], y_limits, 'r', 'LineWidth', 2);
    
    % Calculate and plot the alpha 0.05 interval
    lower_bound = prctile(results(i).r, alpha/2 * 100);
    upper_bound = prctile(results(i).r, (1 - alpha/2) * 100);
    plot([lower_bound, lower_bound], y_limits, 'g--', 'LineWidth', 2);
    plot([upper_bound, upper_bound], y_limits, 'g--', 'LineWidth', 2);
    
    hold off;
    xlabel('r Value');
    ylabel('Frequency');
    legend('Random r Values', 'True r Value', 'Alpha 0.05 Interval');
end


% I think Results should be shown in a matrix or table format?

% Sample size is small (8) so, i would trust more the randomization test than the parametric(?)
% But both tests show that the data is not correlated
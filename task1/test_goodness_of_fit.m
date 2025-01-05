% TEST_GOODNESS_OF_FIT Tests the goodness of fit for given data against specified distributions.
%
% Inputs:
%   data       - A vector of observed data points.
%   dist_names - A cell array of strings, where each string is the name of a
%                distribution to test against.
%
% Outputs:
%   best_fit   - The distribution that best fits the data.
%   chi_squared - A vector of chi-squared statistics for each distribution.
%   p_values   - A vector of p-values corresponding to the chi-squared statistics.
%

function [best_fit, chi_squared, p_values] = test_goodness_of_fit(data, dist_names)
% Initialize outputs
chi_squared = zeros(length(dist_names), 1);  % Store Chi-squared values for each distribution
p_values = zeros(length(dist_names), 1);     % Store p-values for each distribution
fits = cell(length(dist_names), 1);           % Store fitted distribution objects
results = cell(length(dist_names), 3);        % Preallocate results cell array

% Calculate histogram data
num_bins = round(sqrt(length(data)));          % Number of bins (rule of thumb)
bin_edges = linspace(min(data), max(data), num_bins);

% For each distribution in dist_names
for i = 1:length(dist_names)
    % Fit the distribution to the data
    fits{i} = fitdist(data, dist_names{i});

    % Calculate expected counts from the fitted distribution's PDF
    bin_centers = (bin_edges(1:end-1) + bin_edges(2:end)) / 2; % Calculate bin centers
    fitted_pdf = pdf(fits{i}, bin_centers); % Get the PDF values at the bin centers
    expected_count = fitted_pdf * length(data) * diff(bin_edges(1:2)); % Multiply by the total number of data points

    % Perform Chi-squared goodness-of-fit test using chi2gof
    [h, p, stats] = chi2gof(data, 'Expected', expected_count, 'nbins', num_bins -1 );

    % Store the Chi-squared statistic and p-value
    chi_squared(i) = stats.chi2stat;
    p_values(i) = p;

    % Store results in a cell array
    results{i, 1} = dist_names{i};
    results{i, 2} = p;
    results{i, 3} = stats.chi2stat;

end

% Identify the best fit (distribution with the smallest Chi-squared statistic)
[~, best_index] = max(p_values); % Find the index of the distribution with the highest p-value
best_fit = fits{best_index};  % Best fit distribution object

% Display the best fitting distribution and its Chi-squared statistic
fprintf('Best fit distribution: %s\n', dist_names{best_index});
fprintf('Chi-squared value for the best fit: %.4f\n', chi_squared(best_index));
fprintf('p-value for the best fit: %.4f\n', p_values(best_index));

row_height = 25; % Ύψος κάθε γραμμής
num_rows = length(dist_names); % Αριθμός γραμμών
uitable_height = max(300, row_height * (num_rows + 1)); % Προσαρμογή για τις γραμμές και την επικεφαλίδα
uitable_width = 600; % Πλάτος του πίνακα (μπορεί να προσαρμοστεί αν χρειάζεται)

% Δημιουργία του uitable
f = figure('Name', 'Goodness-of-Fit Results', 'NumberTitle', 'off', ...
    'Position', [100, 100, uitable_width, uitable_height]);
uitable('Parent', f, ...
    'Data', results, ...
    'ColumnName', {'Distribution', 'p-value', 'Chi-squared'}, ...
    'Position', [25, 25, uitable_width - 50, uitable_height - 50], ...
    'ColumnWidth', {200, 150, 150}); % Προσαρμογή πλάτους στηλών
end

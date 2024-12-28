data = readtable('TMS.xlsx');

% Extract relevant columns for ED duration with and without TMS
ED_without_TMS = data.EDduration(data.TMS == 0);

% Consider this the mo value
mean_ED_without_TMS = mean(ED_without_TMS);

% Divide into 6 samples depending on the setup value
ED_without_TMS_1 = data.EDduration(data.TMS == 0 & data.Setup == 1);
ED_without_TMS_2 = data.EDduration(data.TMS == 0 & data.Setup == 2);
ED_without_TMS_3 = data.EDduration(data.TMS == 0 & data.Setup == 3);
ED_without_TMS_4 = data.EDduration(data.TMS == 0 & data.Setup == 4);
ED_without_TMS_5 = data.EDduration(data.TMS == 0 & data.Setup == 5);
ED_without_TMS_6 = data.EDduration(data.TMS == 0 & data.Setup == 6);

% Evaluate whether distribution is normal
% Fit a normal distribution to the data
pd = fitdist(ED_without_TMS, 'Normal');
mu = pd.mu;
sigma = pd.sigma;
norm_cdf = @(x) normcdf(x, mu, sigma);

% Perform goodness of fit test for ED duration with TMS
[hypothesis, p] = chi2gof(ED_without_TMS, 'CDF', norm_cdf, 'Alpha', 0.05);
if hypothesis == 0
    hypothesis_string = 'cannot be rejected';
else
    hypothesis_string = 'can be rejected';
end

fprintf('p value: %f\n', p);
fprintf('The distribution of ED without TMS is normal: %s\n', hypothesis_string);

% Normal distribution is not a good fit so we will try with bootstrap


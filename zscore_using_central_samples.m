function [X,sd] = zscore_using_central_samples(X, f)

% Z-scores samples in X, using only values near the median to avoid effects of
% outliers.
% 
% -- Inputs --
% 
% X: vector or matrix of input samples, function operates separately on each column
% 
% f: fraction of samples to use to calculate the standard deviation
% 
% -- Outputs -- 
% 
% X: z-scored samples
% 
% sd: estimate of the standard deviation
% 
% -- Example --
% 
% % standard deviation of a unit-variance Gaussian estimated using the empirical
% % standard deviation or using the method of central samples
% X = 0.25*randn(10000,1);
% std(X)
% [~,sd] = zscore_using_central_samples(X, 0.2)
% 
% % add outliers and repeat
% outliers = randn(size(X))*5;
% outliers(outliers < 10) = 0;
% X = X + outliers;
% std(X)
% [~,sd] = zscore_using_central_samples(X, 0.2)

% 2018-11-20: Altered to make the computation a little simpler

% subtract median
X = X - repmat(median(X), size(X,1), 1);

% estimate standard deviation from central samples
sd = (quantile(X, 0.5+f/2)-quantile(X, 0.5-f/2)) ...
    / (norminv(0.5+f/2,0,1) - norminv(0.5-f/2,0,1));
% sd = 2*quantile(abs(X), f) / (norminv(0.5+f/2,0,1) - norminv(0.5-f/2,0,1));

% divide by estimate of the standard deviation
X = X ./ repmat(sd, size(X,1), 1);


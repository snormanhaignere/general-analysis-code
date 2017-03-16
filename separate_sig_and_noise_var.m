function [sig_var, noise_var, total_var, error_var] = ...
    separate_sig_and_noise_var(X)

% Assumes each column of X was created by a fixed signal present throughout all
% columns plus uncorrelated noise, independently sampled for each column. Given
% this assumption, this function estimates the variance of the signal and noise
% separately.
% 
% Used by noisecorr_metrics.
% 
% 2017-03-16: Created, Sam NH

assert(size(X,2)>1);

% demean
X = bsxfun(@minus, X, mean(X,1));

% error of the variance, averaged across all samples
f = @(a,b)var(a-b);
error_var = nanfunc_all_column_pairs(f, X);
error_var = mean(error_var(logical(tril(ones(size(X,2)),-1))));

% noise variance is half of the error variance
noise_var = error_var/2;

% total variance in the noisy signal
total_var = mean(var(X),2);

% variance of the signal assuming uncorrelated noise
sig_var = total_var - noise_var;

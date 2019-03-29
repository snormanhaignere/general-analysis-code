function E = ci_from_samples(X)

% function ci_from_samples(X)
% 
% Computes confidence intervals from a vector of samples (central 95%),
% using the CDF of the samples. If X is a matrix, confidence intervals are
% computed for every column.
% 
% -- Example -- 
% % Confidence intervals for normal distribution are [-1.96, 1.96]
% X = randn(100000,4); 
% ci_from_samples(X)

E = central_interval_from_samples(X,0.05);
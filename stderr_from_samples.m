function E = stderr_from_samples(X)

% function stderr_from_samples(X)
% 
% Computes standard errors from a vector of samples, using
% the CDF of the samples. If X is a matrix, standard errors
% are computed for every column.
% 
% -- Example -- 
% % Standard error for normal distribution is [-1, 1]
% X = randn(100000,4); 
% stderr_from_samples(X)

central_frac = diff(normcdf([-1 1],0,1));
tail_frac = 1-central_frac;
E = central_interval_from_samples(X,tail_frac);
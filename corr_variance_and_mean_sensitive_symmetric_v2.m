function r = corr_variance_and_mean_sensitive_symmetric_v2(X,Y)
% Returns a similarity measure, r, that quantifies the similarity of two input vectors, X and Y.
% When X and Y are zero mean and have equal variance it is equivalent to the pearson correlation of X and Y.
% 
% X and Y can be matrices of the same size, in which case the function
% returns the result of applying the function to corresponding columns.
% 
% Example:
% sig = rand(100,5);
% X = randn(100,5) + sig;
% Y = randn(100,5) + sig;
% diag(corr(X,Y))'
% corr_variance_and_mean_sensitive_symmetric_v2(zscore(X), zscore(Y))
% corr_variance_and_mean_sensitive_symmetric_v2(X,Y)
% corr_variance_and_mean_sensitive_symmetric_v2(X*10,Y)
% corr_variance_and_mean_sensitive_symmetric_v2(X+10,Y+10)

% norm
r = 1 - sum((X-Y).^2) ./ (sum(X.^2) + sum(Y.^2));
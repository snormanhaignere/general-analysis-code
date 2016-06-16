function [r2, r2_std_err, r2_smps, r, r_std_err, r_smps, Yh] = normalized_crossval_regression(X,Y,nsmps)
% function [r2, r2_err, r2_smps, r, r_err, r_smps, yh] = normalized_crossval_regression(X,Y,nsmps)
% 
% Calculates the correlation between predicted and measured data vectors, normalized by the 
% reliability of the data and predictors. Predictions are computed using cross-validated 
% regression in a leave-one-out style. See crossval_regression.m.
% 
% Returns the normalized pearson correlation and signed square of the pearson correlation (e.g. sign(r) * r^2),
% which provides an estimate of explained variance unaffected by measurement noise.
% 
% If nsmps > 1, bootstrapping is used to compute standard errors. Otherwise an analytic approximation is used.
% nsmps defaults to 1000.
% 
% Example:
% X = randn(100,10);
% B = randn(10,1);
% Y = (X*B)*ones(1,20) + randn(100,20)*4; % 20 independent samples with independent noise
% 
% % R^2 without normalization
% [~,r_without_norm] = crossval_regression(X,Y(:,1));
% r2_without_norm = sign(r_without_norm) * r_without_norm.^2
% 
% % R^2 with normalization
% [r2, r2_std_err] = normalized_crossval_regression(X,Y,1000)

% demean data
% for i = 1:size(Y,2)
%     Y(:,i) = Y(:,i) - mean(Y(:,i));
% end

% number of data points
n = size(Y,1); 

% predict response using pls
Yh = nan(size(Y));
for i = 1:size(Y,2)
    Yh(:,i) = crossval_regression(X,Y(:,i));
end

if nargin < 3
   nsmps = 1000;
end

% standard errors
if nsmps > 1 % errors via bootstrapping
    [r,r_std_err,r_smps] = bootstrapped_normalized_correlation(Y,Yh,nsmps);
    r2 = sign(r).*r.^2;
    r2_std_err = sign(r_std_err).*r_std_err.^2;
    r2_smps = sign(r_smps).*r_smps.^2;
else % errors via analytic approximation
    r = normalized_correlation(Y,Yh);
    r_std_err = r2rerr(r, n);
    r2 = sign(r).*r.^2;
    r2_std_err = sign(r_std_err).*r_std_err.^2;
    r_smps = [];
    r2_smps = [];
end

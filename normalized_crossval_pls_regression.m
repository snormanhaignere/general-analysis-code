function [r2, r2_err, r2_smps, r, r_err, r_smps, yh] = normalized_crossval_pls_regression(X,y,K,nsmps)

% regression with pls regularization
% predicted correlations are normalized by the reliability of the data, y, and the predictions, yh
% if K > number of regressors, i.e. size(X,2), than least-squares regression is used
% if nsmps > 1, bootstrapping is used to estimate standard errors

error('Needs to be debugged before using');

% demean data
for i = 1:size(y,2)
    y(:,i) = y(:,i) - mean(y(:,i));
end

% matrix sizes
n = size(y,1); % number of data points
p = size(X,2); % number of regressors

% default K for pls
if nargin < 3
    K = round(n/6);
end
K = min(K,p);

% predict response using pls
yh = nan(size(y));
for i = 1:size(y,2)
    yh(:,i) = pls_leave_one_out(X,y(:,i),K);
end

% normalized correlation with bootstrapping
if nargin < 4
   nsmps = 1;
end

if nsmps > 1
    [r,r_err,r_smps] = bootstrapped_normalized_correlation(y,yh,nsmps);
    r2 = sign(r).*r.^2;
    r2_err = sign(r_err).*r_err.^2;
    r2_smps = sign(r_smps).*r_smps.^2;
else
    r = normalized_correlation(y,yh);
    r_err = r2rerr(r, n);
    r2 = sign(r).*r.^2;
    r2_err = sign(r_err).*r_err.^2;
    r_smps = [];
    r2_smps = [];
end

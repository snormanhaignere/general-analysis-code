function [beta_contrast, logP, contrast_variance, df, R] ...
    = regress_stats_ols(Y, X, C, varargin)

% Ordinary least-squares regression with corresponding stats, assuming
% independent errors

% dimensionality of feature matrix
[N,P] = size(X);

% check size
assert(N == size(Y,1));

% set contrast matrix to identity
if nargin < 3
    C = eye(P);
end

% demean X and Y
Y = bsxfun(@minus, Y, mean(Y));
X = bsxfun(@minus, X, mean(X));

% regress
B = pinv(X) * Y;

% apply contrat vector
beta_contrast = C' * B;

% variance of residual
df = size(Y,1) - size(X,2) - 1;
E = (Y - X*B);
R = sum(E.^2)/df;

% variance of contrast
contrast_variance = diag(C' * pinv(X) * pinv(X)' * C) * R;

% convert to a p-value
% -> contrast x voxel
tstat = beta_contrast ./ sqrt(contrast_variance);
logP = -sign(tstat).*log10(2*tpvalue_copy(-abs(tstat), df)); % two-tailed
logP(contrast_variance == 0) = NaN;
logP(isnan(contrast_variance)) = NaN;
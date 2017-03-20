function [r, num, denom] = normalized_correlation_within_folds_v2(X, Y, folds, varargin)

% Calculates the noise-corrected correlation but within folds. Useful in
% combination with regression scripts (e.g.
% regress_predictions_from_3way_crossval.m)
% 
% Very similar to version 1, but relies on normalized_correlation_v2.m instead
% of normalized_correlation.m
% 
% % -- Simple Example -- 
% 
% % create a correlated signal
% N = 1000;
% Xsig = randn(N, 1);
% Ysig = Xsig + randn(N, 1);
% 
% % add i.i.d. noise to each column
% X = bsxfun(@plus, Xsig, 1*randn(N, 3));
% Y = bsxfun(@plus, Ysig, 1*randn(N, 2));
% 
% % true signal correlation and estimate
% folds = subdivide(N,3);
% corr(Xsig, Ysig)
% normalized_correlation_within_folds_v2(X, Y, folds)
%
% 2017-03-16: Created by Sam NH
% 
% 2017-03-17: Fixed small syntax bug
% 
% 2017-03-19: Numerator and denominator now averaged before division for
% stability, Sam NH

I.same_noise = false;
I.metric = 'pearson';
I = parse_optInputs_keyvalue(varargin, I);

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

% r_folds = nan(n_folds, 1);
num_folds = nan(n_folds, 1);
denom_folds = nan(n_folds, 1);
for i = 1:n_folds
    xi = i == folds;
    [~, num_folds(i), denom_folds(i)] = normalized_correlation_v2(...
        X(xi,:), Y(xi,:), 'same_noise', I.same_noise, 'metric', I.metric);
end

num = mean(num_folds);
denom = mean(denom_folds);
r = num/denom;
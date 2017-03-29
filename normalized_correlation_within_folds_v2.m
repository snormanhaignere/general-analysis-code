function [r, Xvar, Yvar, XYcov] = normalized_correlation_within_folds_v2(X, Y, folds, varargin)

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
% 
% 2017-03-29: Instead of averaging numerator and denominator, averages variances
% and covariances.

I.same_noise = false;
I.metric = 'pearson';
I = parse_optInputs_keyvalue(varargin, I);

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

% r_folds = nan(n_folds, 1);
Xvar_folds = nan(n_folds, 1);
Yvar_folds = nan(n_folds, 1);
XYcov_folds = nan(n_folds, 1);
for i = 1:n_folds
    xi = i == folds;
    [~, Xvar_folds(i), Yvar_folds(i), XYcov_folds(i)] = normalized_correlation_v2(...
        X(xi,:), Y(xi,:), 'same_noise', I.same_noise, 'metric', I.metric);
end

Xvar = mean(Xvar_folds);
Yvar = mean(Yvar_folds);
XYcov = mean(XYcov_folds);

% compute the desired metric
switch I.metric
    case 'pearson'
        if Xvar < 0 || Yvar < 0
            r = NaN;
        else
            r = XYcov / sqrt(Xvar * Yvar);
        end
    case 'demeaned-squared-error'
        if (Xvar + Yvar) < 0
            r = NaN;
        else
            % r = 1 - (Xvar + Yvar - 2*XYcov) / (Xvar + Yvar);
            r = XYcov / ((Xvar + Yvar)/2);
        end
    otherwise
        error('No matching case for metric %s\n', metric);
end
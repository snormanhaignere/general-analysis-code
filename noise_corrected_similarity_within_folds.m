function [r, Xvar, Yvar, XYcov] = noise_corrected_similarity_within_folds(X, Y, folds, varargin)

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
%
% 2017-03-29: Added 'variance_centering' option
%
% 2017-03-31: Made it an option as to whether variance and covariance terms are
% averaged across folds before being combined into the desired metric

I.same_noise = false;
I.metric = 'pearson';
I.variance_centering = false;
I.average_before_combining_terms = true;
I = parse_optInputs_keyvalue(varargin, I);

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

Xvar_folds = nan(n_folds, 1);
Yvar_folds = nan(n_folds, 1);
XYcov_folds = nan(n_folds, 1);
for i = 1:n_folds
    xi = i == folds;
    [~, Xvar_folds(i), Yvar_folds(i), XYcov_folds(i)] = ...
        noise_corrected_similarity(...
        X(xi,:), Y(xi,:), 'same_noise', I.same_noise, 'metric', I.metric, ...
        'variance_centering', I.variance_centering);
end

% average terms across folds
Xvar = mean(Xvar_folds);
Yvar = mean(Yvar_folds);
XYcov = mean(XYcov_folds);

% calculate metric
if I.average_before_combining_terms
    r = simfunc(Xvar, Yvar, XYcov, I.metric);
else
    r = nanmean(simfunc(Xvar_folds, Yvar_folds, XYcov_folds, I.metric));
end

function r = simfunc(Xvar, Yvar, XYcov, metric)

switch metric
    case 'pearson'
        r = XYcov ./ sqrt(Xvar .* Yvar);
        r(Xvar < 0 | Yvar < 0) = NaN;
    case 'demeaned-squared-error'
        r = XYcov / ((Xvar + Yvar)/2);
        r((Xvar + Yvar) < 0) = NaN;
    otherwise
        error('No matching case for metric %s\n', metric);
end


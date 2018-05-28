function [r, Px, Py, XY, Mx, My] = noise_corrected_similarity_within_folds(X, Y, folds, varargin)

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
% 
% 2017-09-26: Made it possible to compute the normalized squared error, which
% requires correlation and power statistics instead of covariance and variance
% statistics, as well as mean statistics

I.same_noise = false;
I.metric = 'pearson';
I.variance_centering = false;
I.average_before_combining_terms = true;
I.only_cross_column_cov = false;
I = parse_optInputs_keyvalue(varargin, I);

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

% compute the within fold stats
Px_folds = nan(n_folds, 1);
Py_folds = nan(n_folds, 1);
XY_folds = nan(n_folds, 1);
Mx_folds = nan(n_folds, 1);
My_folds = nan(n_folds, 1);
for i = 1:n_folds
    xi = i == folds;
    [~, Px_folds(i), Py_folds(i), XY_folds(i), Mx_folds(i), My_folds(i)] = ...
        noise_corrected_similarity(...
        X(xi,:), Y(xi,:), 'same_noise', I.same_noise, 'metric', I.metric, ...
        'variance_centering', I.variance_centering, ...
        'only_cross_column_cov', I.only_cross_column_cov);
end

% average terms across folds
Px = mean(Px_folds);
Py = mean(Py_folds);
XY = mean(XY_folds);
Mx = mean(Mx_folds);
My = mean(My_folds);

% calculate metric
if I.average_before_combining_terms
    r = simfunc(Px, Py, XY, Mx, My, I.metric);
else
    r = nanmean(simfunc(Px_folds, Py_folds, XY_folds, Mx_folds, My_folds, I.metric));
end

function r = simfunc(Px, Py, XY, Mx, My, metric)

% compute the desired metric
switch metric
    case 'pearson'
        if Px < 0 || Py < 0
            r = NaN;
        else
            r = XY / sqrt(Px * Py);
        end
    case 'demeaned-squared-error'
        if (Px + Py) < 0
            r = NaN;
        else
            r = XY / ((Px + Py)/2);
        end
    case 'unnormalized-squared-error'
        r = Px + Py - 2*XY;
    case 'normalized-squared-error'
        a = Px + Py - 2*XY;
        b = Px + Py - 2*Mx.*My;
        if b < 0
            r = NaN;
        else
            r = 1 - a./b;
        end
    otherwise
        error('No matching case for metric %s\n', I.metric);
end
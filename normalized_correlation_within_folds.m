function r = normalized_correlation_within_folds(...
    X, Y, folds, metric, throw_warning)

% Calculates the noise-corrected correlation but within folds. Useful in
% combination with regression scripts.
%
% see regress_predictions_from_3way_crossval.m
%
% Example with a perfectly correlated signal and independent noise.
% Normalized correlation should equal 1.
% nd = 10000;
% sig = randn(nd,1);
% X = randn(nd,3) + sig*ones(1,3);
% Y = randn(nd,4)*2 + sig*ones(1,4);
% folds = subdivide(nd, 10);
% r = normalized_correlation_within_folds(X,Y,folds,'demeaned-squared-error')
%
% 2016-11-18: Created by Sam NH
%
% 2016-12-20: Made it possible to calculate rank correlation in addition to
% pearson (default)
% 
% 2017-03-15: Streamlined code, added a new correlation_type (variance-sensitive)

if nargin < 4
    metric = 'pearson';
end

if nargin < 5
    throw_warning = true;
end

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

rXX = nan(n_folds,1);
rYY = nan(n_folds,1);
rXY = nan(n_folds,1);

for i = 1:n_folds
    
    switch metric
        case {'pearson', 'r2'}
            similarity_func = @nancorr;
        case {'rank', 'rank-r2'}
            similarity_func = @nanrankcorr;
        case 'demeaned-squared-error'
            similarity_func = @nancorr_variance_sensitive;
        otherwise
            keyboard;
            error('No matching case');
    end
    
    averaging_func = @(a,k)tanh(mean(atanh(mytril(a,k))));
    
    xi = i == folds;
    rXX(i) = averaging_func( similarity_func(X(xi,:), X(xi,:)), -1);
    rYY(i) = averaging_func( similarity_func(Y(xi,:), Y(xi,:)), -1);
    rXY(i) = averaging_func( similarity_func(X(xi,:), Y(xi,:)), 0);
    
end

if mean(rXX) <= 0 || mean(rYY) <=0
    if throw_warning
        warning('Average test-retest r < 0');
    end
    r = NaN;
    return;
end

r = mean(rXY) / (sqrt(mean(rXX)) * sqrt(mean(rYY)));
if any(strcmp(metric, {'r2', 'demeaned-squared-error', 'rank-r2'}))
    r = sign_and_square(r);
end

function Y = mytril(Y,k)

Y = Y(logical(tril(ones(size(Y)),k)));



function r = normalized_correlation_within_folds(X,Y,folds)

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
% r = normalized_correlation_within_folds(X,Y,folds)
% 
% 2016-11-18: Created by Sam NH

% order folds
[~,~,folds] = unique(folds(:));
n_folds = max(folds);

rXX = nan(n_folds,1);
rYY = nan(n_folds,1);
rXY = nan(n_folds,1);

for i = 1:n_folds
    xi = i == folds;
    rXX(i) = tanh(mean(atanh(mytril(nancorr(X(xi,:)),-1))));
    rYY(i) = tanh(mean(atanh(mytril(nancorr(Y(xi,:)),-1))));
    rXY(i) = tanh(mean(atanh(mytril(nancorr(X(xi,:), Y(xi,:)),0))));
end

if mean(rXX) <= 0 || mean(rYY) <=0
    warning('Average test-retest r < 0');
    r = NaN;
    return;
end

r = mean(rXY) / (sqrt(mean(rXX)) * sqrt(mean(rYY)));

function Y = mytril(Y,k)

Y = Y(logical(tril(ones(size(Y)),k)));
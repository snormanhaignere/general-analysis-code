function explainable_variance = ...
    explainable_variance_from_regression(F, Y, n_folds, method, K, varargin)

% 3-way cross-validated
for i = 1:size(Y,2);
    Yh = regress_predictions_from_3way_crossval(F, Y, n_folds, method, K, varargin);
end

explainable_variance = normalized_correlation(Y, Yh);

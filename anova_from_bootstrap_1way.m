function p = anova_from_bootstrap_1way(X, empirical_variance)

% Performs an analysis similar to a 1-way ANOVA but suited for bootstrapped
% samples. Assumes the input matrix X contains sample means, calculated using
% bootstrapping. Columns are assumed to correspond to different conditions and
% rows to samples.

assert(all(~isnan(X(:))));
dims = size(X);

% demean columns
column_means = mean(X,1);
X_col_demeaned = X - repmat(column_means, [dims(1), ones(size(dims(2:end)))]);

% null variance
null_variance = var(X_col_demeaned, [], 2);

% p-value
p = mean(empirical_variance < null_variance);
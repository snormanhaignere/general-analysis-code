function p = anova_from_bootstrap_1way(X)

% Performs an analysis similar to an 1-way ANOVA but suited for bootstrapped
% samples. Assumes the input matrix X contains sample means, calculated using
% bootstrapping. Columns are assumed to correspond to different conditions and
% rows to samples.

assert(all(~isnan(X(:))));
dims = size(X);

% demean entire matrix
X_matrix_demeaned = X - mean(X(:));

% demean columns
column_means = mean(X,1);
X_col_demeaned = X - repmat(column_means, [dims(1), ones(size(dims(2:end)))]);

% null and sample statistic
null = sum(X_col_demeaned.^2, 2);
sample_stat = mean( sum(X_matrix_demeaned.^2, 2), 1);

% p-value
p = mean(sample_stat < null);
function [X_folds, fold_indices, fold_sizes] = create_folds(X, n_folds)

% Divides matrix or column vector X into folds with approximately equal numbers
% of rows.

% check that X is a matrix or a column vector
assert(size(X,1) > 1)

% number of rows
n_rows = size(X,1);

% size of each fold
fold_sizes = floor(n_rows/n_folds) * ones(1, n_folds);
fold_sizes(1 : rem(n_rows,n_folds)) = fold_sizes(1 : rem(n_rows,n_folds)) + 1;
assert(sum(fold_sizes) == n_rows);

% indices for each fold
fold_indices = cell(1,n_folds);
for i = 1:n_folds
    fold_indices{i} = (1:fold_sizes(i)) + sum(fold_sizes(1:i-1));
end

% extract features and data
X_folds = cell(1,n_folds);
for i = 1:n_folds
    X_folds{i} = X(fold_indices{i},:);
end
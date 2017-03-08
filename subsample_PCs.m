function Y = subsample_PCs(X, variance_threshold)

% Selects a reduced number of PCs for an input matrix X that explain more than a
% given amount of the variance. The threshold is determined by the second
% argument. Useful for regression.

% SVD
[U,S,~] = svd(X, 'econ');

% fraction of variance explained as a function of the number of components
eigs = diag(S).^2;
exvar = cumsum(eigs)/sum(eigs);

% number of components needed to explain more than the desired threshold
num_components = find(exvar > variance_threshold, 1);

% return just those components
Y = U(:,1:num_components) * S(1:num_components,1:num_components);
function [yh, r, weights] = crossval_L2_regression_loo(F,y,K,n_folds)


% cross-validated r and squared error
% weights

% dimensions of feature matrix
[N,P] = size(F); %#ok<ASGLU>

% check y is a vector and dimensions match
assert(isvector(y));
assert(length(y) == N);

% number of folds
if nargin < 4
    n_folds = N;
end

% divide data into folds
cell(1)

% scale K values based on first singular value
[~,S,~] = svd(F,'econ');
lambda = K * S(1,1).^2 * 0.01;

% column vector
y = y(:);

% number of components to test
n_K = length(K);

% calculate predictions
yh = nan(N, n_K);
for i = 1:N
    
    % train and test indices
    train_inds = setdiff(1:N, i);
    test_inds = i;
    
    % predictions
    B = ridge(y(train_inds),F(train_inds,:),lambda,0);
    yh(i,:) = [1, F(test_inds,:)] * B;
    
end

% correlate predictions with data
r = corr(yh, y);

% calculate weights using all of the data
weights = ridge(y,F,K,0);

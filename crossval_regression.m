function [yh, r, weights] = crossval_regression(F,y)
% function yh = crossval_regression(F,y)
% 
% Cross-validated regression, using leave-one-out style analysis.
% F is a [M x N] regression matrix, and y is a [M x 1] data vector.
% Returns a prediction vector, yh, where each element of yh(i) is estimated
% from all other elements/features, e.g. F(:,~=i) and y(~=i).
% 
% The correlation between the actual and predicted vector is also returned. 
% 
% Example:
% F = randn(100,10);
% B = randn(10,1);
% y = F*B + randn(100,1);
% yh = crossval_regression(F,y);
% corr(yh,y)

% dimensions of feature matrix
[N,P] = size(F);

% check y is a vector and dimensions match
assert(isvector(y));
assert(length(y) == N);

% column vector
y = y(:);

% calculate predictions
yh = nan(N, 1);
for i = 1:N
    
    train_inds = setdiff(1:N, i);
    test_inds = i;
    n_train_inds = length(train_inds);
    n_test_inds = length(test_inds);
    
    beta = pinv([ones(n_train_inds,1), F(train_inds,:)]) * y(train_inds);
    yh(i) = [ones(n_test_inds,1), F(test_inds,:)] * beta;
        
end

% correlation predictions with data
r = corr(yh, y);

% weights
weights = pinv([ones(N,1), F]) * y;
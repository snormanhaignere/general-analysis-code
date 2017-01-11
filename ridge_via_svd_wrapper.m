function B = ridge_via_svd_wrapper(Y,X,K,std_feats,demean_feats)

% Performs ridge regression via the SVD of the feature matrix X. Unlike builtin
% function ridge, this function avoids computing very large covariance matrices
% when there are many more features than datapoints.
%
% Relies on the fact that the ridge solution can be computed as:
%
% [U,S,V] = svd(X); V * (S^2 + k(i)*eye(size(S,1))) * S * U' * Y
%
% The code computes this solution is a slightly more efficient manner.
%
% If D > N for [N,D] = size(X), then the number of multiplications involved in
% computing the ridge estimate is N^2 + N*D + N, and thus the time should be
% roughly linear in the total number of elements of the matrix.
%
% The feature matrix is z-scored and the data vector y is demeaned.
% The weights returned however are modified so as to be applicable to the
% original feature matrix. The predicted response of the linear model is:
%
% [ones(size(X,1), 1), X] * b
%
% % -- Example: Built-in and custom give same result --
% X = rand(5,10);
% Y = rand(5,1);
% B = ridge(Y,X,1,0)
% B = ridge_via_svd_wrapper(Y,X,1)
%
% % -- Example: Predictions --
% X = randn(100,200);
% Y = X * randn(200,1) + randn(100,1) + 10;
% B = ridge_via_svd_wrapper(Y,X,100);
% figure;
% plot(Y, [ones(size(X,1),1), X]*B, 'o');
%
% % -- Example: Custom is much faster when there are many features --
% X = rand(100,4000);
% Y = rand(100,1);
% tic; B = ridge(Y,X,1,0); toc;
% tic; B = ridge_via_svd_wrapper(Y,X,1); toc;
%
% % -- Example: ridge shrinks weights --
% X = randn(100,100);
% Y = X * randn(100,1) + 10 + randn(100,1) + 5;
% b_ridge = ridge_via_svd_wrapper(Y,X,[0 30 1000]);
% figure;
% plot(1:100, b_ridge(2:end,:), 'o');
%
% 2016-11-30: Created, Sam NH
%
% 2016-12-29: Modified to use a two helper functions (svd_for_regression.m and
% ridge_via_svd.m) and to allow multiple data vectors, specified columns of
% input matrix Y, Sam NH
%
% 2016-01-10 - Made it possible to NOT demean the features and data


% whether or not to z-score
if nargin < 4
    std_feats = true;
end

if nargin < 5
    demean_feats = true;
end

% check data and features have equal numbers of samples
assert(size(Y,1) == size(X,1));

% format featuers and compute SVD
[U, s, V, mX, normX] = svd_for_regression(X, std_feats, demean_feats);

% compute ridge solution
B = nan(size(X,2), length(K), size(Y,2));
for i = 1:size(Y,2)
    if demean_feats
        y = Y(:,i) - mean(Y(:,i));
    else
        y = Y(:,i);
    end
    B(:,:,i) = ridge_via_svd(y, U, s, V, K);
end

% rescale b
B = bsxfun(@times, B, 1./normX');

% add beta for ones regressor
if demean_feats
    beta_ones = nan(1, length(K), size(Y,2));
    for i = 1:size(Y,2)
        beta_ones(1,:,i) = mean(Y(:,i))-mX * B(:,:,i);
    end
    B = cat(1, beta_ones, B);
else
    B = cat(1, zeros(1, length(K), size(Y,2)), B);
end
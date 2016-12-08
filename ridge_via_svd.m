function b = ridge_via_svd(y,X,k,std_feats)

% Performs ridge regression via the SVD of the feature matrix X. Unlike builtin
% function ridge, this function avoids computing very large covariance matrices
% when there are many more features than datapoints.
% 
% Relies on the fact that the ridge solution can be computed as:
% 
% [U,S,V] = svd(X); V * (S^2 + k(i)*eye(size(S,1))) * S * U' * y
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
% y = rand(5,1);
% b = ridge(y,X,1,0)
% b = ridge_via_svd(y,X,1)
% 
% % -- Example: Predictions --
% X = randn(100,200);
% y = X * randn(200,1) + randn(100,1) + 10;
% b = ridge_via_svd(y,X,100);
% figure;
% plot(y, [ones(size(X,1),1), X]*b, 'o');
% 
% % -- Example: Custom is much faster when there are many features --
% X = rand(100,4000);
% y = rand(100,1);
% tic; b = ridge(y,X,1,0); toc;
% tic; b = ridge_via_svd(y,X,1); toc;
% 
% % -- Example: ridge shrinks weights --
% X = randn(100,100);
% y = X * randn(100,1) + 10 + randn(100,1) + 5;
% b_ridge = ridge_via_svd(y,X,[0 30 1000]);
% figure;
% plot(1:100, b_ridge(2:end,:), 'o');
% 
% 2016-11-30: Created, Sam NH

% whether or not to z-score
if nargin < 4
    std_feats = true;
end

% number of regularization constants
nK = length(k);

% number of features and data-points
[N,D] = size(X);
assert(size(y,1) == N && size(y,2) == 1);

% de-mean or zscore features
if std_feats
    normfac = std(X);
else
    normfac = ones(1,size(X,2));
end
mX = mean(X);
Xz = bsxfun(@minus, X, mX);
Xz = bsxfun(@times, Xz, 1./normfac);

% demean y
ym = y - mean(y);

% svd of input
[U,S,V] = svd(Xz, 'econ');
s = diag(S); % singular values

% correlation of principal components with the demeaned data vector
Uty = U' * ym;

% betas
b = nan(D, nK);
for i = 1:nK
    r = s ./ (s.^2 + k(i));
    b(:,i) = V * (r .* Uty); % weight principal components and transform back
end

% e = ym - Xz * b

% rescale b
b = bsxfun(@times, b, 1./normfac');

% add beta for ones regressor
b = [mean(y)-mX * b; b];

% e = y - [ones(N,1), X] * b

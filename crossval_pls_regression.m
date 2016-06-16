function [Yh, best_yh, best_r, best_K] = crossval_pls_regression(X,y,K)
% function [yh, best_yh, best_r, best_K] = crossval_pls_regression(X,y,K)
% 
% Cross-validated partial-least squares regression, using leave-one-out style analysis.
% X is a [M x N] regression matrix, and y is a [M x 1] data vector.
% K indicates the number of components to use in the PLS regression analysis.
% If K is a vector, the regression analysis is performed for all values of K.
% 
% Yh is a vector or matrix with the prediction vectors for each value of K.
% best_yh is the prediction vector with the minimum correlation with y.
% best_r is the correlation between y and best_yh.
% best_K is the k-value corresponding to the prediction vector with the minimum correlation.
% 
% Example:
% X = randn(100,10);
% B = randn(10,1);
% y = X*B + randn(100,1);
% X_plus_rand = [X,randn(100,90)];
% yh_pls = crossval_pls_regression(X_plus_rand,y,10);
% corr(yh_pls,y)
% yh_least_squares = crossval_pls_regression(X_plus_rand,y,100);
% corr(yh_least_squares,y)

error('Needs to be debugged before using.');

% y = y-mean(y);
% X = X - ones(size(X,1),1)*mean(X);
n = length(y);
p = size(X,2);
Yh = nan(n,length(K));
for i = 1:n
    for j = 1:length(K)
        xi = setdiff(1:n,i);
        if K(j) >= p % least squares
            beta = pinv(X(xi,:))*y(xi);
            Yh(i,j) = X(i,:)*beta;
        else % pls
            [P,~,T,~] = plsregress(X(xi,:),y(xi),K(j));
            beta = pinv(T)*y(xi);
            Yh(i,j) = X(i,:)*pinv(P')*beta;
        end
    end
end

all_r = corr(Yh,y);
[best_r,xi] = max(all_r);
best_K = K(xi);
best_yh = Yh(:,xi);


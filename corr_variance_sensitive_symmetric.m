function r = corr_variance_sensitive_symmetric(X,Y)
% Returns a similarity measure, r, that quantifies the similarity of two input vectors, X and Y.
% When X and Y have equal variance it is equivalent to the pearson correlation of X and Y.
% 
% X and Y can be matrices of the same size, in which case the function
% returns the result of applying the function to corresponding columns.
% 
% Example:
% sig = randn(100,5);
% X = randn(100,5) + sig*10;
% Y = randn(100,5) + sig;
% diag(corr(X,Y))'
% corr_variance_sensitive_symmetric(zscore(X), zscore(Y))
% corr_variance_sensitive_symmetric(X,Y)
% corr_variance_sensitive_symmetric(X*10,Y)
% corr_variance_sensitive_symmetric(X+10,Y+10)

X = X - ones(size(X,1),1)*mean(X);
Y = Y - ones(size(Y,1),1)*mean(Y);
r = 1 - sum((X-Y).^2) ./ (sum(X.^2) + sum(Y.^2));

% 1 - var(X-Y) / (var(X) + var(Y))
% 1 - (var(X) + var(Y) - 2*cov(X,Y)) / (var(X) + var(Y))
% cov(X,Y) / (var(X)/2 + var(Y)/2)
% 
% X1 = X + Nx1
% X2 = X + Nx2
% Y1 = X + Ny1
% Y2 = X + Ny2
% 
% var(X) = (var(X1)/2 + var(X2)/2) - var(X1-X2)/2
% var(Y) = (var(Y1)/2 + var(Y2)/2) - var(Y1-Y2)/2
function r = sqerr_norm(X,Y)

% r = sqerr_norm(X,Y)
% 
% % Example:
% sig = rand(100,5);
% X = randn(100,5) + sig;
% Y = randn(100,5) + sig;
% diag(corr(X,Y))'
% sqerr_norm(zscore(X), zscore(Y))
% sqerr_norm(X,Y)
% sqerr_norm(X*10,Y)
% sqerr_norm(X+10,Y+10)

assert(all(size(X)==size(Y)));
r = 1 - mean((X-Y).^2) ./ (var(X,1) + var(Y,1));
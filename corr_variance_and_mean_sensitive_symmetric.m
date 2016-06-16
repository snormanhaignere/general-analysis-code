function r = corr_variance_and_mean_sensitive_symmetric(X,Y)
% Returns a similarity measure, r, that quantifies the similarity of two input vectors, X and Y.
% r is equal to the projection of the vector X onto Y, after and normalizing the two vectors by the norm of Y.
% When X and Y are zero mean and have equal variance it is equivalent 
% to the pearson correlation of X and Y: corr_variance_and_mean_sensitive_assymetric(zscore(X),zscore(Y)) is equivalent to diag(corr(X,Y))' 
% 
% X and Y can be matrices of the same size, in which case the function returns the variance and mean sensitive 
% correlation between corresponding column vectors in the two matrices.
% 
% Example:
% sig = rand(100,5);
% X = rand(100,5) + sig;
% Y = rand(100,5) + sig;
% diag(corr(X,Y))'
% corr_variance_and_mean_sensitive_symmetric(zscore(X),zscore(Y))
% corr_variance_and_mean_sensitive_symmetric(X,Y)
% corr_variance_and_mean_sensitive_symmetric(X,Y*2)
% corr_variance_and_mean_sensitive_symmetric(Y*2,X)

% norm
[M,~] = size(X);
normY = sqrt(sum(Y.^2));
normX = sqrt(sum(X.^2));
normY_matrix = ones(M,1)*normY;
normX_matrix = ones(M,1)*normX;

% project X onto Y if norm of Y is larger
xi = normY > normX;
r = nan(1,size(X,2));
r(xi) = sum((Y(:,xi)./normY_matrix(:,xi)).*(X(:,xi)./normY_matrix(:,xi)));

% project Y onto X if norm of X is larger
xi = normY <= normX;
r(xi) = sum((X(:,xi)./normX_matrix(:,xi)).*(Y(:,xi)./normX_matrix(:,xi)));

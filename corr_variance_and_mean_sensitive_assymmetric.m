function r = corr_variance_and_mean_sensitive_assymmetric(X,Y)
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
% corr_variance_and_mean_sensitive_assymmetric(zscore(X),zscore(Y))
% corr_variance_and_mean_sensitive_assymmetric(X,Y)
% corr_variance_and_mean_sensitive_assymmetric(X,Y*2)
% corr_variance_and_mean_sensitive_assymmetric(X*2,Y)

% norm
[M,~] = size(X);
normY = sqrt(sum(Y.^2));
normY_matrix = ones(M,1)*normY;

% X onto Y
r = sum((Y./normY_matrix).*(X./normY_matrix));
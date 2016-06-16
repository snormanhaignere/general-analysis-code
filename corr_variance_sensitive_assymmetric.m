function r = corr_variance_sensitive_assymmetric(X,Y)
% Returns a similarity measure, r, that quantifies the similarity of two input vectors, X and Y.
% r is equal to the projection of the vector X onto Y, after demeaning the two vectors, and normalizing the two vectors by the norm of Y.
% When X and Y have equal variance it is equivalent to the pearson correlation of X and Y.
% 
% X and Y can be matrices of the same size, in which case the function returns the assymetric, variance-sensitive 
% correlation between corresponding column vectors of the two matrices.
% 
% Example:
% sig = rand(100,5);
% X = rand(100,5) + sig;
% Y = rand(100,5) + sig;
% X_unit_var = X ./ (ones(100,1)*std(X));
% Y_unit_var = Y ./ (ones(100,1)*std(Y));
% diag(corr(X,Y))'
% corr_variance_sensitive_assymmetric(X_unit_var, Y_unit_var)
% corr_variance_sensitive_assymmetric(X,Y)
% corr_variance_sensitive_assymmetric(X,Y*2)
% corr_variance_sensitive_assymmetric(X*2,Y)

% norm
[M,~] = size(X);
X = X - ones(M,1)*mean(X);
Y = Y - ones(M,1)*mean(Y);
normY = sqrt(sum(Y.^2));
normY_matrix = ones(M,1)*normY;

% project X onto Y
r = sum((Y./normY_matrix).*(X./normY_matrix));

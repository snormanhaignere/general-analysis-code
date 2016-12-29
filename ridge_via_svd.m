function b = ridge_via_svd(y,U,s,V,k)

% Efficiently calculates beta weights from ridge regression analysis given the
% SVD (F = U*diag(S)*V') of a feature matrix. See ridge_via_svd_wrapper for
% details.

D = size(V,1);
nK = length(k);

% correlation of principal components with the demeaned data vector
Uty = U' * y;

% betas
b = nan(D, nK);
for i = 1:nK
    r = s ./ (s.^2 + k(i));
    b(:,i) = V * (r .* Uty); % weight principal components and transform back
end
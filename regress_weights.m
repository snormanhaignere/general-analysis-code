function B = regress_weights(y, U, s, V, mF, normF, method, K, demean_feats)

% check there are no NaNs
assert(all(~isnan(y)));

% de-mean data
if demean_feats
    ym = y-mean(y);
else
    ym = y;
end

% weights using all of the data
switch method
    case 'least-squares'
        B = V * ((1./s) .* (U' * ym));
        
    case 'pcreg' % principal components regression
        n_K = length(K);
        B = nan(size(V,1), n_K);
        for j = 1:n_K
            B(:,j) = V(:,1:K(j)) * ((1./s(1:K(j))) .* (U(:,1:K(j))' * ym));
        end
        
    case 'ridge'
        B = ridge_via_svd(ym, U, s, V, K);
        
    case 'pls'
        n_K = length(K);
        B = nan(size(U,2)+1, n_K);
        for j = 1:n_K
            Z = bsxfun(@times, U, s');
            [~,~,~,~,B(:,j)] = plsregress(Z, ym, K(j));
        end
        B = B(2:end,:);
        B = V * B;
        
    case 'lasso'
        B = lasso(U * diag(s) * V', ym, 'Lambda', K, 'Standardize', false);
        
    otherwise
        error('No valid method for %s\n', method);
end

% rescale weights to remove effect of normalization
B = bsxfun(@times, B, 1./normF');

% add ones regressor
if demean_feats
    B = [mean(y) - mF * B; B];
else
    B = [zeros(1,size(B,2)); B];
end
function [yh, r, weights] = crossval_pls_regression_loo2fold(F,y,K)

% dimensions of feature matrix
[N,P] = size(F);

% check y is a vector and dimensions match
assert(isvector(y));
assert(length(y) == N);

% column vector
y = y(:);

% number of components to test
n_K = length(K);

% calculate predictions
yh = nan(N, n_K);
for i = 1:N
    train_inds = setdiff(1:N, i);
    test_inds = i;
    
    for j = 1:n_K
        [~,~,~,~,beta] = plsregress(F(train_inds,:),y(train_inds),K(j));
        yh(i,j) = [1, F(test_inds,:)] * beta;
    end
end

% correlation predictions with data
r = corr(yh, y);

% calculate weights using all of the data
weights = nan(P, n_K);
for j = 1:n_K
    [~,~,~,~,beta] = plsregress(F,y,K(j));
    weights(:,j) = beta(2:end);
end
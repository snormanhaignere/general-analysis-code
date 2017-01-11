function [B, best_K, mse, r, mse_bestK] = ...
    regress_weights_from_2way_crossval(F, Y, folds, method, ...
    K, std_feats, groups, demean_feats)

% [B, best_K, mse, r] = ...
%   regress_weights_from_2way_crossval(F, Y, folds, method, K, std_feats, groups)
%
% Estimates regression weights using regularized, cross-validatd regression.
% Available methods include 'ridge', 'pls', 'lasso', 'pcreg' (principal
% components regression). The regularization parameter (K) is varied (i.e.
% lambda for ridge/lasso, the number of components pls / pcreg), and the weights
% with the lowest cross-validated MSE are returned. 
% 
% -- Inputs -- 
% 
% F: [sample x dimension] feature matrix
% 
% Y: [sample x D] data matrix
% 
% folds: number of folds if scalar (default is 10), or alternatively a vector
% of size equal to the number of samples that indicates which fold each sample
% belongs to (e.g. [1 1 1 2 2 2 3 3 3 ...])
% 
% method: 'ridge' (default), 'pls', 'lasso', 'pcreg', or 'least-squares'
% 
% K: the regularization parameter (see code for defaults, for ridge K = lambda =
% 2.^(-30:30))
% 
% std_feats: whether or not to z-score features (i.e. zscore(F)) before
% regression (default: true); the features are always demeaned
% 
% groups: an optional vector argument (default = []) that specifies which of a N
% groups each feature belongs to (e.g. [1 1 1 2 2 2 3 3 3 3 3 ...]). If this
% group vector is specified, then the features are normalized such that the
% features of each group have the same overall power. This can be useful if
% there are many more features in one group than another.
% 
% -- Worked Example --
%
% % features, weights and noisy data
% N = 100;
% P = 100;
% sig = 3;
% F = randn(N, P);
% w = randn(P, 1);
% y = F * w + sig * randn(N,1);
%
% % least-squares weights
% folds = 10;
% [b, ~, ls_mse] = ...
%     regress_weights_from_2way_crossval(F, y, folds, 'least-squares');
%
% % plot least-squares weights
% b = pinv([ones(N,1), F]) * y;
% figure;
% plot(w, b(2:end), 'o');
% l = max([max(abs(xlim)), max(abs(ylim))]);
% xlim([-l l]); ylim([-l l]);
% xlabel('True Weights'); ylabel('Estimated Weights');
% title('Least Squares');
% drawnow;
%
% % regularized methods
% methods = {'ridge', 'pls', 'lasso'};
%
% for i = 1:length(methods);
%
%     % regularizatio parameter K (i.e. lambda for ridge)
%     switch methods{i}
%         case 'ridge'
%             K = 2.^(-30:30);
%         case 'pls'
%             K = 1:30;
%         case 'lasso'
%             K = 2.^(-20:20);
%     end
%
%     % 10-fold ridge regression
%     folds = 10;
%     [b, best_K, mse] = ...
%         regress_weights_from_2way_crossval(F, y, folds, methods{i}, K);
%
%     % plot weights
%     figure;
%     plot(w, b(2:end), 'o');
%     l = max([max(abs(xlim)), max(abs(ylim))]);
%     xlim([-l l]); ylim([-l l]);
%     xlabel('True Weights'); ylabel('Estimated Weights');
%     title(methods{i});
%     drawnow;
%
%     % MSE vs. regularization parameter
%     figure; hold on;
%     if log10(range(K)) > 3
%         xaxis = log2(K);
%         xlabel('log2(K)');
%     else
%         xaxis = K;
%         xlabel('K');
%     end
%     plot(xaxis, mse);
%     h1 = plot(xaxis, mean(mse), 'k--', 'LineWidth', 3);
%     h2 = plot(xlim, mean(ls_mse)*[1 1], 'r--', 'LineWidth', 3);
%     ylabel('MSE');
%     legend([h1, h2], {'Mean MSE across Folds', 'Least Squares Baseline'});
%     title(methods{i});
%     drawnow;
%
% end
%
% 2016-11-30: Modified to use a faster ridge code (see ridge_via_svd.m), Sam NH
% 
% 2016-12-8 Changed how features are standardized prior to regression, Sam NH
% 
% 2016-12-29 Made it possible to input multiple data vectors as a matrix. This
% is useful because the much of the computation involves the SVD of the feature
% matrix, which only needs to be done once. Removed parameter that allowed one
% to specify the number of components to use per group, and now instead just
% fix the overall power of the features in each group. Sam NH
% 
% 2016-01-10 - Made it possible to NOT demean the features and data

% dimensions of feature matrix
[N,P] = size(F);

% check dimensions of Y and F match
assert(size(Y,1) == N);
D = size(Y,2);

% number of folds
if nargin < 3 || isempty(folds)
    folds = 10;
end

% ridge is the default method
if nargin < 4 || isempty(method)
    method = 'ridge';
end

% default range of regularization parameters
if nargin < 5 || isempty(K)
    switch method
        case 'least-squares'
            K = [];
        case 'ridge'
            K = 2.^(-30:30);
        case 'pls'
            K = 1:round(P/3);
        case 'pcreg'
            K = 1:round(P/3);
        case 'lasso'
            K = 2.^(-20:20);
        otherwise
            error('No valid method for %s\n', method);
    end
end

% by default standardize features
if nargin < 6 || isempty(std_feats)
    std_feats = true;
end

% groups
if nargin < 7 || isempty(groups)
    groups = ones(1,P);
end
groups = groups(:)';
n_groups = max(groups);
assert(all((1:n_groups) == unique(groups)));
assert(length(groups) == P);

if nargin < 8 || isempty(demean_feats)
    demean_feats = true;
end

if isscalar(folds)
    n_folds = folds;
    fold_indices = subdivide(N, folds);
    clear folds;
else
    assert(isvector(folds));
    [~,~,fold_indices] = unique(folds(:));
    n_folds = max(fold_indices);
    clear folds;
end

% number of components to test
n_K = length(K);

% calculate predictions
mse = nan(n_folds, max(n_K,1), D);
r = nan(n_folds, max(n_K,1), D);
for test_fold = 1:n_folds
    
    % train and testing folds
    test_fold_indices = fold_indices == test_fold;
    train_fold_indices = ~test_fold_indices;
    
    % concatenate training data
    y_train = Y(train_fold_indices,:);
    F_train = F(train_fold_indices,:);
    clear train_fold_indices;
    
    % format features and compute svd
    [U, s, V, mF, normF] = svd_for_regression(...
        F_train, std_feats, demean_feats, groups);
    clear F_train;
    
    % prediction from test features
    F_test = F(test_fold_indices, :);
    F_test = [ones(size(F_test, 1), 1), F_test]; %#ok<AGROW>
    for i = 1:D

        % estimate weights from training data
        B = regress_weights(y_train(:,i), U, s, V, mF, normF, method, K, demean_feats);
        
        % test data
        yh = F_test * B;
        clear B;
        
        % accuracy metrics
        err = bsxfun(@minus, yh, Y(test_fold_indices,i));
        mse(test_fold,:,i) = nanmean(err.^2, 1);
        r(test_fold,:,i) = nancorr(yh, Y(test_fold_indices,i));
        clear yh err;
        
    end        
    clear F_test U s V mF normF;
    clear test_fold_indices;
    
end

if strcmp(method, 'least-squares')
    best_K = nan(1,D);
    mse_bestK = nan(1,D);
else
    best_K = nan(1,D);
    mse_bestK = nan(1,D);
    for i = 1:D
        % best regularization value
        [~, best_K_index] = min( mean(mse(:,:,i), 1), [], 2 );
        best_K(i) = K(best_K_index);
        mse_bestK(i) = mean(mse(:, best_K_index,i));
        
        % check if the best regularizer is on the boundary
        if strcmp(method, 'ridge') && (best_K_index == 1 || best_K_index == n_K)
            warning('Best regularizer is on the boundary of possible values\nK=%f', best_K(i));
        elseif strcmp(method, 'pls') && best_K_index == n_K
            warning('Best regularizer is on the boundary of possible values\nK=%f', best_K(i));
        end
    end
end

% estimate weights using all of the data
[U, s, V, mF, normF] = svd_for_regression(F, std_feats, demean_feats, groups);
B = nan(P+1, D);
for i = 1:D
    B(:,i) = regress_weights(Y(:,i), U, s, V, mF, normF, method, best_K(i), demean_feats);
end
clear U s V mF normF;

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

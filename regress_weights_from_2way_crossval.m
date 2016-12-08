function [B, best_K, mse, r, mse_bestK] = ...
    regress_weights_from_2way_crossval(F, y, folds, method, K, std_feats)

% [B, best_K, mse, r] = ...
%     regress_weights_from_2way_crossval(F, y, folds, method, K)
%
% Estimates regression using N-fold cross-validation. Available methods include
% 'ridge', 'pls', and 'lasso'. The set of regularization parameters K
% (e.g. lambda for ridge) can be specified. The parameters are varied and the
% weights for the parameter with the lowest cross-validated MSE are returned.
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


% dimensions of feature matrix
[N,P] = size(F);

% check y is a column vector and dimensions match the feature matrix
assert(iscolumn(y) && length(y) == N);

% number of folds
if nargin < 3 || isempty(folds)
    folds = N;
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
        case 'lasso'
            K = 2.^(-20:20);
        otherwise
            error('No valid method for %s\n', method);
    end
end

if nargin < 6 || isempty(std_feats)
    std_feats = true;
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
mse = nan(n_folds, max(n_K,1));
r = nan(n_folds, max(n_K,1));
for test_fold = 1:n_folds
    
    % train and testing folds
    test_fold_indices = fold_indices == test_fold;
    train_fold_indices = ~test_fold_indices;
    
    % concatenate training data
    F_train = F(train_fold_indices,:);
    y_train = y(train_fold_indices,:);
    
    % estimate weights from training data
    B = regress_weights(F_train, y_train, method, K, std_feats);
    clear F_train y_train;
    
    % prediction from test features
    F_test = F(test_fold_indices, :);
    F_test = [ones(size(F_test, 1), 1), F_test]; %#ok<AGROW>
    yh = F_test * B;
    clear F_test B;
    
    % accuracy metrics
    err = bsxfun(@minus, yh, y(test_fold_indices));
    mse(test_fold,:) = nanmean(err.^2, 1);
    r(test_fold,:) = nancorr(yh, y(test_fold_indices));
    clear yh;
    
end

if strcmp(method, 'least-squares')
    best_K = [];
    mse_bestK = [];
else
    % best regularization value
    [~, best_K_index] = min( mean(mse, 1), [], 2 );
    best_K = K(best_K_index);
    mse_bestK = mean(mse(:, best_K_index));
    
    % check if the best regularizer is on the boundary
    if strcmp(method, 'ridge') && (best_K_index == 1 || best_K_index == n_K)
        warning('Best regularizer is on the boundary of possible values\nK=%f', best_K);
    elseif strcmp(method, 'pls') && best_K_index == n_K
        warning('Best regularizer is on the boundary of possible values\nK=%f', best_K);
    end
end

% estimate weights using all of the data
B = regress_weights(F, y, method, best_K, std_feats);

function B = regress_weights(F, y, method, K, std_feats)

% remove NaN values
xi = ~isnan(y);
y = y(xi);
F = F(xi,:);
clear xi;

% number of features
P = size(F,2);

% number of regularization parameters
n_K = length(K);

% de-mean or z-score features
if std_feats
    normfac = std(F);
else
    normfac = ones(1,size(F,2));
end
mF = mean(F);
Fz = bsxfun(@minus, F, mF);
Fz = bsxfun(@times, Fz, 1./normfac);

% de-mean data
ym = y-mean(y);

% weights using all of the data
switch method
    case 'least-squares'
        B = pinv(Fz) * ym;
        
    case 'pcreg' % principal components regression
        [U,S,V] = svd(Fz,'econ');
        B = nan(P, n_K);
        inv_sing = 1./diag(S);
        for j = 1:n_K
            B(:,j) = V(:,1:K(j)) * (inv_sing(1:K(j)) .* (U(:,1:K(j))' * ym));
        end
        
    case 'ridge'
        B = ridge_via_svd(ym, Fz, K, false);
        B = B(2:end,:);
        
    case 'pls'
        B = nan(P+1, n_K);
        for j = 1:n_K
            [~,~,~,~,B(:,j)] = plsregress(Fz, ym, K(j));
        end
        B = B(2:end,:);
        
    case 'lasso'
        B = lasso(Fz, ym, 'Lambda', K, 'Standardize', false);
        
    otherwise
        error('No valid method for %s\n', method);
end

% rescale weights to remove effect of normalization
B = bsxfun(@times, B, 1./normfac');

% add ones regressor
B = [mean(y) - mF * B; B];
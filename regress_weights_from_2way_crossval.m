function [B, best_K, mse, r, demeaned_mse, normalized_mse] = ...
    regress_weights_from_2way_crossval(F, Y, varargin)

% [B, best_K, mse, r] = ...
%   regress_weights_from_2way_crossval(F, Y, varargin)
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
% -- Optional Inputs -- 
% 
% optional inputs are specified as name-value pairs: (..., 'NAME', VALUE, ...)
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
% regularization_metric: metric used to select the desired reguralization paramter.
% Options are mean squared error ('unnormalized-squared-error' the default),
% pearson correlation coefficient ('pearson'), or a normalized version of the
% squared error that is similar to a correlation ('demeaned-squared-error').
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
%     regress_weights_from_2way_crossval(F, y, ...
%     'folds', folds, 'method', 'least-squares');
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
%         regress_weights_from_2way_crossval(F, y, ...
%         'folds', folds, 'method', methods{i}, 'K', K);
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
% 2017-01-10 Made it possible to NOT demean the features and data
% 
% 2017-04-05 Made it possible to choose a desired metric to assess
% cross-validated performance instead of just using the MSE.
% 
% 2017-04-05/06 Changed how optional inputs are handled
% 
% 2017-10-05 Added the normalized squared error metric

% dimensions of feature matrix
[n_samples, n_features] = size(F);

% check dimensions of Y and F match
assert(size(Y,1) == n_samples);
n_data_vecs = size(Y,2);

% optional arguments
I.folds = 5;
I.method = 'ridge';
I.K = [];
I.std_feats = true;
I.groups = ones(1, n_features);
I.demean_feats = true;
I.regularization_metric = 'unnormalized-squared-error';
I.warning = true;
I = parse_optInputs_keyvalue(varargin, I);

% regularization parameter
if isempty(I.K)
    switch I.method
        case 'least-squares'
            I.K = [];
        case 'ridge'
            I.K = 2.^(-100:100);
        case 'pls'
            I.K = 1:round(n_features/3);
        case 'pcreg'
            I.K = 1:round(n_features/3);
        case 'lasso'
            I.K = 2.^(-100:100);
        otherwise
            error('No valid method for %s\n', I.method);
    end
end

% groups
I.groups = I.groups(:)';
n_groups = max(I.groups);
assert(all((1:n_groups) == unique(I.groups)));
assert(length(I.groups) == n_features);

% folds
if isscalar(I.folds)
    n_folds = I.folds;
    fold_indices = subdivide(n_samples, I.folds);
else
    assert(isvector(I.folds));
    [~,~,fold_indices] = unique(I.folds(:));
    n_folds = max(fold_indices);
end

% number of components to test
n_K = length(I.K);

% calculate predictions
mse = nan(n_folds, max(n_K, 1), n_data_vecs);
r = nan(n_folds, max(n_K, 1), n_data_vecs);
demeaned_mse = nan(n_folds, max(n_K, 1), n_data_vecs);
normalized_mse = nan(n_folds, max(n_K, 1), n_data_vecs);
for test_fold = 1:n_folds
    
    % train and testing folds
    test_fold_indices = fold_indices == test_fold;
    train_fold_indices = ~test_fold_indices;
    
    % concatenate training data
    y_train = Y(train_fold_indices, :);
    F_train = F(train_fold_indices, :);
    clear train_fold_indices;
    
    % format features and compute svd
    [U, s, V, mF, normF] = svd_for_regression(...
        F_train, I.std_feats, I.demean_feats, I.groups);
    clear F_train;
    
    % prediction from test features
    F_test = F(test_fold_indices, :);
    F_test = [ones(size(F_test, 1), 1), F_test]; %#ok<AGROW>
    for i = 1:n_data_vecs
        
        % estimate weights from training data
        B = regress_weights(y_train(:,i), U, s, V, ...
            mF, normF, I.method, I.K, I.demean_feats);
        
        % test data
        yh = F_test * B;
        clear B;
        
        % accuracy metrics
        err = bsxfun(@minus, yh, Y(test_fold_indices,i));
        mse(test_fold,:,i) = nanmean(err.^2, 1);
        r(test_fold,:,i) = nancorr(yh, Y(test_fold_indices,i));
        demeaned_mse(test_fold,:,i) = ...
            nancorr_variance_sensitive_symmetric(yh, Y(test_fold_indices,i));
        normalized_mse(test_fold,:,i) = ...
            nancorr_normalized_squared_error(yh, Y(test_fold_indices,i));
        clear yh err;
        
    end
    clear F_test U s V mF normF;
    clear test_fold_indices;
    
end

switch I.regularization_metric
    case 'pearson'
        stat = r;
    case 'unnormalized-squared-error'
        stat = -mse;
    case 'demeaned-squared-error'
        stat = demeaned_mse;
    case 'normalized-squared-error'
        stat = normalized_mse;
    otherwise
        error('No matching case for crossval_metric %s\n', I.regularization_metric);
end

if strcmp(I.method, 'least-squares')
    best_K = nan(1, n_data_vecs);
else
    best_K = nan(1, n_data_vecs);
    for i = 1:n_data_vecs
        % best regularization value
        [~, best_K_index] = nanmax(nanmean(stat(:,:,i), 1), [], 2);
        best_K(i) = I.K(best_K_index);
        
        % check if the best regularizer is on the boundary
        if I.warning
            if strcmp(I.method, 'ridge') && (best_K_index == 1 || best_K_index == n_K)
                warning('Best regularizer is on the boundary of possible values\nK=%f', best_K(i));
            elseif strcmp(I.method, 'pls') && best_K_index == n_K
                warning('Best regularizer is on the boundary of possible values\nK=%f', best_K(i));
            end
        end
    end
end

% estimate weights using all of the data
[U, s, V, mF, normF] = svd_for_regression(F, I.std_feats, I.demean_feats, I.groups);
B = nan(n_features+1, n_data_vecs);
for i = 1:n_data_vecs
    B(:,i) = regress_weights(Y(:,i), U, s, V, mF, normF, I.method, best_K(i), I.demean_feats);
end
clear U s V mF normF;



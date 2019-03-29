function classify_2way_crossval(F, Y, varargin)

% dimensions of feature matrix
[n_samples, n_features] = size(F);

% check dimensions of Y and F match
assert(size(Y,1) == n_samples);
n_data_vecs = size(Y,2);

% optional arguments
I.folds = 5;
I.method = 'svm';
I.K = [];
I.std_feats = true;
I.groups = ones(1, n_features);
I.demean_feats = true;
I.warning = true;
I = parse_optInputs_keyvalue(varargin, I);

% % regularization parameter
% if isempty(I.K)
%     switch I.method
%         case 'least-squares'
%             I.K = [];
%         case 'ridge'
%             I.K = 2.^(-100:100);
%         case 'pls'
%             I.K = 1:round(n_features/3);
%         case 'pcreg'
%             I.K = 1:round(n_features/3);
%         case 'lasso'
%             I.K = 2.^(-100:100);
%         otherwise
%             error('No valid method for %s\n', I.method);
%     end
% end

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

n_folds = 5;
music_labels = int32(ismember(C.category_assignments, [7, 8]));
CVpartition = cvpartition(music_labels, 'KFold', n_folds);

tps = (0:3:50)+1;
accuracy = nan(n_folds, length(tps));
for i = 1:length(tps)
    
    F = squeeze(S.Dg(tps(i),:,4,:));
    
    for k = 1:n_folds
        svm = fitcsvm(F(CVpartition.training(k), :), music_labels(CVpartition.training(k)));
        P = predict(svm, F(CVpartition.test(k), :));
        accuracy(k, i) = mean(music_labels(CVpartition.test(k))' == P);
    end
end
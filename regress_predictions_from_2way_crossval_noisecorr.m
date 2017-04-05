function [B, best_K, r_bestK, r] = ...
    regress_predictions_from_2way_crossval_noisecorr(F, Y, varargin)

% dimensions of feature matrix
[n_samples, n_features] = size(F);

% check dimensions of Y and F match
assert(size(Y,1) == n_samples);
n_reps = size(Y,2);
n_data_vecs = size(Y,3);

% optional arguments
I.folds = 10;
I.method = 'ridge';
I.K = [];
I.std_feats = true;
I.groups = ones(1, n_features);
I.demean_feats = true;
I.metric = 'demeaned-squared-error';
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
            error('No valid method for %s\n', method);
    end
end

% groups
I.groups = I.groups(:)';
n_groups = max(I.groups);
assert(all((1:n_groups) == unique(I.groups)));
assert(length(I.groups) == n_features);

% fold indices
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
Xvar = nan(n_folds, n_K, n_data_vecs);
Yvar = nan(n_folds, n_K, n_data_vecs);
XYcov = nan(n_folds, n_K, n_data_vecs);
for test_fold = 1:n_folds
    
    % train and testing folds
    test_fold_indices = fold_indices == test_fold;
    train_fold_indices = ~test_fold_indices;
    
    % concatenate training data
    Y_train = Y(train_fold_indices,:,:);
    F_train = F(train_fold_indices,:);
    clear train_fold_indices;
    
    % format features and compute svd
    [U, s, V, mF, normF] = svd_for_regression(...
        F_train, I.std_feats, I.demean_feats, I.groups);
    clear F_train;
    
    % prediction from test features
    F_test = F(test_fold_indices, :);
    F_test = [ones(size(F_test, 1), 1), F_test]; %#ok<AGROW>
    
    for i = 1:n_data_vecs
        
        % predictions
        Yh = nan(size(F_test,1), n_reps, n_K);
        for j = 1:n_reps
            
            % estimate weights from training data
            B = regress_weights(Y_train(:, j, i), U, s, V, ...
                mF, normF, I.method, I.K, I.demean_feats);
            
            % test data
            Yh(:,j,:) = F_test * B;
            clear B;
                        
        end
        
        % similarity metrics applied to predictions
        for j = 1:n_K
            [~, Xvar(test_fold, j, i), Yvar(test_fold, j, i), XYcov(test_fold, j, i)] = ...
                noise_corrected_similarity( Y(test_fold_indices,:,i), Yh(:,:,j), ...
                'metric', I.metric);
        end
        clear Yh
    end
    clear F_test U s V mF normF;
    clear test_fold_indices;
    
end

% r: n_K x n_data_vecs
Xvar = squeeze_dims(mean(Xvar,1),1);
Yvar = squeeze_dims(mean(Yvar,1),1);
XYcov = squeeze_dims(mean(XYcov,1),1);
switch I.metric
    case 'pearson'
        r = XYcov ./ sqrt(Xvar .* Yvar);
        r(Xvar < 0 | Yvar < 0) = NaN;
    case 'demeaned-squared-error'
        r = XYcov ./ ((Xvar + Yvar)/2);
        r((Xvar + Yvar) < 0) = NaN;
    otherwise
        error('No matching case for metric %s\n', I.metric);
end

best_K = nan(1,n_data_vecs);
r_bestK = nan(1,n_data_vecs);
for i = 1:n_data_vecs
    % best regularization value
    [~, best_K_index] = max(r(:,i));
    best_K(i) = I.K(best_K_index);
    r_bestK(i) = r(best_K_index, i);
    
    % check if the best regularizer is on the boundary
    if strcmp(I.method, 'ridge') && (best_K_index == 1 || best_K_index == n_K)
        warning('Best regularizer is on the boundary of possible values\nK=%f', best_K(i));
    elseif strcmp(I.method, 'pls') && best_K_index == n_K
        warning('Best regularizer is on the boundary of possible values\nK=%f', best_K(i));
    end
end

% estimate weights using all of the data
[U, s, V, mF, normF] = svd_for_regression(F, I.std_feats, I.demean_feats, I.groups);
B = nan(n_features+1, n_data_vecs);
for i = 1:n_data_vecs
    B(:,i) = regress_weights(squeeze_dims(mean(Y(:,:,i), 2), 2), ...
        U, s, V, mF, normF, I.method, best_K(i), I.demean_feats);
end
clear U s V mF normF;
function [B, best_K, r_bestK, r] = ...
    regress_weights_from_2way_crossval_noisecorr(F, Y, varargin)

% 2017-09-27: Added normalized squared error metric.

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
I.warning = true;
I.std_feats = true;
I.groups = ones(1, n_features);
I.demean_feats = true;
I.regularization_metric = 'demeaned-squared-error';
I.correction_method = 'variance-based';
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
switch I.correction_method
    case 'variance-based'
        Xvar = nan(n_folds, n_K, n_data_vecs);
        Yvar = nan(n_folds, n_K, n_data_vecs);
        XYcov = nan(n_folds, n_K, n_data_vecs);
        Mx = nan(n_folds, n_K, n_data_vecs);
        My = nan(n_folds, n_K, n_data_vecs);
    case 'correlation-based'
        Rx = nan(n_folds, n_K, n_data_vecs);
        Ry = nan(n_folds, n_K, n_data_vecs);
        Rxy = nan(n_folds, n_K, n_data_vecs);
    otherwise
        error('Switch statement fell through');
end

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
        
        % compute regularization_metric used to choose regularization parameter
        for j = 1:n_K
            switch I.correction_method
                case 'variance-based'
                    [~, Xvar(test_fold, j, i), Yvar(test_fold, j, i), ...
                        XYcov(test_fold, j, i), ...
                        Mx(test_fold, j, i), My(test_fold, j, i)] = ...
                        noise_corrected_similarity( Y(test_fold_indices,:,i), Yh(:,:,j), ...
                        'metric', I.regularization_metric);
                case 'correlation-based'
                    assert(strcmp(I.regularization_metric, 'pearson'));
                    [~, ~, Rx(test_fold, j, i), Ry(test_fold, j, i), Rxy(test_fold, j, i)] = ...
                        normalized_correlation(Y(test_fold_indices,:,i), Yh(:,:,j), ...
                        'z_average', false, 'warning', false);
                otherwise
                    error('Switch statement fell through');
            end
            
        end
        clear Yh
    end
    clear F_test U s V mF normF;
    clear test_fold_indices;
    
end

% r: n_K x n_data_vecs

switch I.correction_method
    
    case 'variance-based'
        Xvar = squeeze_dims(mean(Xvar,1),1);
        Yvar = squeeze_dims(mean(Yvar,1),1);
        XYcov = squeeze_dims(mean(XYcov,1),1);
        Mx = squeeze_dims(mean(Mx,1),1);
        My = squeeze_dims(mean(My,1),1);
        switch I.regularization_metric
            case 'pearson'
                r = XYcov ./ sqrt(Xvar .* Yvar);
                r(Xvar < 1e-10 | Yvar < 1e-10) = NaN;
            case 'demeaned-squared-error'
                r = XYcov ./ ((Xvar + Yvar)/2);
                r((Xvar + Yvar) < 1e-10) = NaN;
            case 'unnormalized-squared-error'
                r = Xvar + Yvar - 2*XYcov;
                r = -r;
            case 'normalized-squared-error'
                a = Xvar + Yvar - 2*XYcov;
                b = Xvar + Yvar - 2*Mx.*My;
                r = 1 - a./b;
                r(b < 1e-10) = NaN;
                clear a b;
            otherwise
                error('No matching case for regularization_metric %s\n', ...
                    I.regularization_metric);
        end
    case 'correlation-based'
        Rx = squeeze_dims(mean(Rx,1),1);
        Ry = squeeze_dims(mean(Ry,1),1);
        Rxy = squeeze_dims(mean(Rxy,1),1);
        switch I.regularization_metric
            case 'pearson'
                r = mean(Rxy ./ (sqrt(Rx) .* sqrt(Ry)));
                r(Rx < 0 | Ry < 0) = NaN;
            otherwise
                error('No matching case for regularization_metric %s\n', ...
                    I.regularization_metric);
        end
    otherwise
        error('Switch statement fell through');
end

best_K = nan(1,n_data_vecs);
r_bestK = nan(1,n_data_vecs);
for i = 1:n_data_vecs
    % best regularization value
    [~, best_K_index] = nanmax(r(:,i));
    best_K(i) = I.K(best_K_index);
    r_bestK(i) = r(best_K_index, i);
    
    % check if the best regularizer is on the boundary
    if I.warning
        if strcmp(I.method, 'ridge') && (best_K_index == 1 || best_K_index == n_K)
            warning('Best regularizer is on the boundary of possible values\nK=%f', best_K(i));
        elseif strcmp(I.method, 'pls') && best_K_index == n_K
            warning('Best regularizer is on the boundary of possible values\nK=%f', best_K(i));
        end
    end
end

% estimate weights using all of the data
[U, s, V, mF, normF] = svd_for_regression(F, I.std_feats, I.demean_feats, I.groups);
B = nan(n_features+1, n_reps, n_data_vecs);
for i = 1:n_data_vecs
    for j = 1:n_reps
        B(:, j, i) = regress_weights(Y(:, j, i), ...
            U, s, V, mF, normF, I.method, best_K(i), I.demean_feats);
    end
end
clear U s V mF normF;

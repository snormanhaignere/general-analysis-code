function [Yh, test_fold_indices]  = ...
    regress_predictions_from_3way_crossval_noisecorr(F, Y, varargin)

% dimensions of feature matrix
[n_samples, n_features] = size(F);

% check dimensions of Y and F match
assert(size(Y,1) == n_samples);
n_reps = size(Y,2);
n_data_vecs = size(Y,3);

% optional arguments
I.test_folds = 2;
I.train_folds = 2;
I.method = 'ridge';
I.K = [];
I.std_feats = true;
I.groups = ones(1, n_features);
I.demean_feats = true;
I.regularization_metric = 'demeaned-squared-error';
I.correction_method = 'variance-based';
I.warning = true;
I.MAT_file = '';
I.F_test = [];
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

% divide signal into folds
if isscalar(I.test_folds)
    n_folds = I.test_folds;
    test_fold_indices = subdivide(n_samples, I.test_folds);
else
    assert(isvector(I.test_folds));
    [~,~,test_fold_indices] = unique(I.test_folds(:));
    n_folds = max(test_fold_indices);
    clear folds;
end

% calculate predictions
Yh = nan(size(Y));
for test_fold = 1:n_folds
    
    fprintf('Test fold %d\n', test_fold); drawnow;
    
    % train and testing folds
    test_samples = test_fold_indices == test_fold;
    
    % within training data divide into folds
    if isscalar(I.train_folds)
        train_fold_indices = I.train_folds;
    elseif isvector(I.train_folds)
        assert(length(I.train_folds) == n_samples);
        train_fold_indices = train_folds(~test_samples);
    else
        error('Failed all conditionals');
    end
    
    % concatenate training data
    F_train = F(~test_samples, :);
    Y_train = Y(~test_samples, :, :);
    
    if strcmp(I.method, 'least-squares')
        B_train = nan(n_features+1, n_reps, n_data_vecs);
        for i = 1:n_data_vecs
            for j = 1:n_reps
                xi = ~isnan(Y_train(:, j, i));
                B_train(:,i) = ...
                    pinv([ones(sum(xi),1), F_train(xi,:)]) * Y_train(xi, j, i);
            end
        end
    else
        tic;
        % estimate regression weights using 2-way cross validation on training set
        B_train = regress_weights_from_2way_crossval_noisecorr(...
            F_train, Y_train, 'folds', train_fold_indices, 'method', ...
            I.method, 'K', I.K, 'std_feats', I.std_feats, 'groups', I.groups, ...
            'regularization_metric', I.regularization_metric, ...
            'correction_method', I.correction_method, ...
            'warning',  I.warning);
        toc;
    end
    
    % can optionally use a different feature set
    if ~isempty(I.F_test)
        assert(all(size(I.F_test) == size(F)));
        F_test = I.F_test(test_samples,:);
    else
        F_test = F(test_samples,:);
    end
    
    % prediction from test features
    F_test = [ones(size(F_test, 1), 1), F_test]; %#ok<AGROW>
    
    % multiply weights from training data against test features
    dims = size(B_train);
    Yh(test_samples,:,:) = reshape(...
        F_test * reshape(B_train, [dims(1), prod(dims(2:end))]), ...
        [size(F_test,1), dims(2:end)]);
    
end

if ~isempty(I.MAT_file)
    save(I.MAT_file, 'Yh', 'test_fold_indices');
end



function [Yh, mse, r, test_fold_indices, B] = ...
    regress_predictions_from_3way_crossval(F, Y, varargin)

% Calculates predictions from using a 3-way cross-validated regression. The data
% is first split into two folds, test and training. The weights of the
% regression analysis are estimated from the training data, and then applied to
% the features of the test data. The weights are themselves chosen using 2-way
% cross-validation (see regress_weights_from_2way_crossval.m) applied to the
% training data.
%
% Available regression methods include 'ridge', 'pls', 'lasso', 'pcreg'
% (principal components regression), and 'least-squares' (no regularization).
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
% test_folds: number of folds to use for the first split into training and test
% data if scalar (default is 10), or alternatively a vector of size equal to
% the number of samples that indicates which fold each sample belongs to (e.g.
% [1 1 1 2 2 2 3 3 3 ...])
%
% method: 'ridge' (default), 'pls', 'lasso', 'pcreg', or 'least-squares'
%
% K: the regularization parameter (see code for defaults, for ridge K = lambda =
% 2.^(-30:30))
%
% train_folds: number of folds to use for the second split within the training
% data if scalar (default is 10), or alternatively a vector of size equal to the
% number of samples that indicates which training fold each sample belongs to
% (e.g. [1 1 1 2 2 2 3 3 3 ...])
%
% MAT_file: a optional MAT file to save results to
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
% crossval_metric: metric used to select the desired reguralization paramter.
% Options are mean squared error ('unnormalized-squared-error' the default),
% pearson correlation coefficient ('pearson'), or a normalized version of the
% squared error that is similar to a correlation ('demeaned-squared-error').
% 
% -- Worked Example --
%
% N = 100;
% P = 100;
% sig = 3;
% F = randn(N, P);
% w = randn(P, 1);
% y = F * w + sig * randn(N,1);
% 
% % least-squares baseline
% folds = 10;
% [ls_yh, ls_mse] = ...
%     regress_predictions_from_3way_crossval(F, y, ...
%     'test_folds', folds, 'train_folds', folds, 'method', 'least-squares');
% 
% % ridge
% [ridge_yh, ridge_mse] = ...
%     regress_predictions_from_3way_crossval(F, y, ...
%     'test_folds', folds, 'train_folds', 10, 'method', 'ridge', 'K', 2.^(-30:30));
% 
% % compare MSE for least-squares and ridge
% figure;
% plot(ls_mse, ridge_mse, 'o');
% l = max([max(abs(xlim)), max(abs(ylim))]);
% xlim([0 l]); ylim([0 l]);
% hold on; plot([0 l], [0 l], 'r--');
% xlabel('Least Squares MSE'); ylabel('Ridge MSE');

% 2016-12-8 Changed how features are standardized prior to regression, Sam NH
%
% 2016-12-29 Made it possible to input multiple data vectors as a matrix. This
% is useful because the much of the computation involves the SVD of the feature
% matrix, which only needs to be done once. Removed parameter that allowed one
% to specify the number of components to use per group, and now instead just
% fix the overall power of the features in each group. Sam NH
% 
% 2017-04-05 Made it possible to choose a desired metric to assess
% cross-validated performance instead of just using the MSE.
% 
% 2017-04-05/06 Changed how optional inputs are handled
% 
% 2018-05-31: Made it possible to swap in a new feature set for test

% dimensions of feature matrix
[n_samples, n_features] = size(F);

% check y is a column vector and dimensions match the feature matrix
assert(size(Y,1) == n_samples);

I.test_folds = 2;
I.train_folds = 2;
I.method = 'ridge';
I.K = [];
I.std_feats = true;
I.groups = ones(1, n_features);
I.demean_feats = true;
I.regularization_metric = 'unnormalized-squared-error';
I.warning = true;
I.MAT_file = '';
I.F_test = [];
I = parse_optInputs_keyvalue(varargin, I);

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
n_data_vecs = size(Y,2);
r = nan(n_folds, n_data_vecs);
Yh = nan(n_samples, n_data_vecs);
if nargout >=5; B = nan(n_features+1, n_data_vecs, n_folds); end
for test_fold = 1:n_folds
    
    % train and testing folds
    test_samples = test_fold_indices == test_fold;
    
    % within training data divide into folds
    if isscalar(I.train_folds)
        train_fold_indices = I.train_folds;
    elseif isvector(I.train_folds)
        assert(length(I.train_folds) == n_samples);
        train_fold_indices = I.train_folds(~test_samples);
    else
        error('Failed all conditionals');
    end
    
    % concatenate training data
    F_train = F(~test_samples,:);
    y_train = Y(~test_samples,:);
    
    if strcmp(I.method, 'least-squares')
        B_train = nan(n_features+1,n_data_vecs);
        for i = 1:n_data_vecs
            xi = ~isnan(y_train(:,i));
            B_train(:,i) = pinv([ones(sum(xi),1), F_train(xi,:)])*y_train(xi,i);
        end
    else
        % estimate regression weights using 2-way cross validation on training set
        B_train = regress_weights_from_2way_crossval(...
            F_train, y_train, 'folds', train_fold_indices, 'method', I.method, ...
            'K', I.K, 'std_feats', I.std_feats, 'groups', I.groups, ...
            'demean_feats', I.demean_feats, ...
            'regularization_metric', I.regularization_metric, ...
            'warning', I.warning);
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
    Yh(test_samples,:) = F_test * B_train;
    
    % accuracy metrics
    r(test_fold,:) = nanfastcorr(Yh(test_samples,:), Y(test_samples,:));
    
    % optionally save weights
    if nargout >= 5
        B(:, :, test_fold) = B_train;
    end
    
end

mse = nanmean((Yh-Y).^2, 1);

if ~isempty(I.MAT_file)
    save(I.MAT_file, 'Yh', 'mse', 'r', 'test_fold_indices');
end






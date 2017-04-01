function [Yh, mse, r, test_fold_indices, B] = ...
    regress_predictions_from_3way_crossval(F, Y, test_folds, method, K, ...
    train_folds, MAT_file, std_feats, groups)

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
% % least-squares baseline
% folds = 10;
% [ls_yh, ls_mse] = ...
%     regress_predictions_from_3way_crossval(F, y, folds, 'least-squares');
%
% % ridge
% [ridge_yh, ridge_mse] = ...
%     regress_predictions_from_3way_crossval(F, y, folds, 'ridge', 2.^(-30:30));
%
% % compare MSE for least-squares and ridge
% figure;
% plot(ls_mse, ridge_mse, 'o');
% l = max([max(abs(xlim)), max(abs(ylim))]);
% xlim([0 l]); ylim([0 l]);
% hold on; plot([0 l], [0 l], 'r--');
% xlabel('Least Squares MSE'); ylabel('Ridge MSE');
%
% 2016-12-8 Changed how features are standardized prior to regression, Sam NH
%
% 2016-12-29 Made it possible to input multiple data vectors as a matrix. This
% is useful because the much of the computation involves the SVD of the feature
% matrix, which only needs to be done once. Removed parameter that allowed one
% to specify the number of components to use per group, and now instead just
% fix the overall power of the features in each group. Sam NH

% dimensions of feature matrix
[N,P] = size(F);

% check y is a column vector and dimensions match the feature matrix
assert(size(Y,1) == N);

% number of folds
if nargin < 3 || isempty(test_folds)
    test_folds = N;
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

if nargin < 8 || isempty(std_feats)
    std_feats = true;
end

% by assign everything to the same group
if nargin < 9
    groups = [];
end

% divide signal into folds
if isscalar(test_folds)
    n_folds = test_folds;
    test_fold_indices = subdivide(N, test_folds);
    clear test_folds;
else
    assert(isvector(test_folds));
    [~,~,test_fold_indices] = unique(test_folds(:));
    n_folds = max(test_fold_indices);
    clear folds;
end

% calculate predictions
D = size(Y,2);
r = nan(n_folds, D);
Yh = nan(N, D);
if nargout >=5; B = nan(P, D, n_folds); end
for test_fold = 1:n_folds
    
    % train and testing folds
    test_samples = test_fold_indices == test_fold;
    
    % within training data divide into folds
    if nargin < 6
        train_fold_indices = test_fold_indices(~test_samples);
    elseif isscalar(train_folds)
        train_fold_indices = train_folds;
    elseif isvector(train_folds)
        assert(length(train_folds) == N);
        train_fold_indices = train_folds(~test_samples);
    else
        error('Failed all conditionals');
    end
    
    % concatenate training data
    F_train = F(~test_samples,:);
    y_train = Y(~test_samples,:);
    
    if strcmp(method, 'least-squares')
        B_train = nan(P+1,D);
        for i = 1:D
            xi = ~isnan(y_train(:,i));
            B_train(:,i) = pinv([ones(sum(xi),1), F_train(xi,:)])*y_train(xi,i);
        end
    else
        % estimate regression weights using 2-way cross validation on training set
        B_train = regress_weights_from_2way_crossval(...
            F_train, y_train, train_fold_indices, method, K, ...
            std_feats, groups);
    end
    
    % prediction from test features
    F_test = F(test_samples,:);
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

if nargin >= 7 && ~isempty(MAT_file)
    save(MAT_file, 'Yh', 'mse', 'r', 'test_fold_indices');
end






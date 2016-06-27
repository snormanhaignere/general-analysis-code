function [yh, mse, r] = ...
    regress_predictions_from_3way_crossval(F, y, folds, method, K, varargin)

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

% dimensions of feature matrix
[N,P] = size(F);

% check y is a column vector and dimensions match the feature matrix
assert(iscolumn(y) && length(y) == N);

% number of folds
if nargin < 3
    folds = N;
end

% ridge is the default method
if nargin < 4
    method = 'ridge';
end

% default range of regularization parameters
if nargin < 5
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

% divide signal into folds
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

% calculate predictions
r = nan(n_folds, 1);
yh = nan(N, 1);
for test_fold = 1:n_folds
        
    % train and testing folds
    test_fold_indices = fold_indices == test_fold;
    train_fold_indices = ~test_fold_indices;
    
    % concatenate training data
    F_train = F(train_fold_indices,:);
    y_train = y(train_fold_indices,:);
    
    % estimate regression weights using 2-way cross validation on training set
    B = regress_weights_from_2way_crossval(...
        F_train, y_train, fold_indices(train_fold_indices), ...
        method, K, varargin{:});
        
    % prediction from test features
    F_test = F(test_fold_indices,:);
    F_test = [ones(size(F_test, 1), 1), F_test]; %#ok<AGROW>
    yh(test_fold_indices) = F_test * B;
    
    % accuracy metrics
    r(test_fold) = corr(yh(test_fold_indices), y(test_fold_indices));
    
end

mse = mean((yh-y).^2, 1);







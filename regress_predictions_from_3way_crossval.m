function [yh, mse, r, test_fold_indices] = ...
    regress_predictions_from_3way_crossval(F, y, test_folds, method, K, ...
    train_folds, MAT_file)

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
r = nan(n_folds, 1);
yh = nan(N, 1);
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
    y_train = y(~test_samples,:);
    
    if strcmp(method, 'least-squares')
        xi = ~isnan(y_train);
        B = pinv([ones(sum(xi),1), F_train(xi,:)])*y_train(xi);
    else
        % estimate regression weights using 2-way cross validation on training set
        B = regress_weights_from_2way_crossval(...
            F_train, y_train, train_fold_indices, method, K);
    end
        
    % prediction from test features
    F_test = F(test_samples,:);
    F_test = [ones(size(F_test, 1), 1), F_test]; %#ok<AGROW>
    yh(test_samples) = F_test * B;
    
    % accuracy metrics
    r(test_fold) = nanfastcorr(yh(test_samples), y(test_samples));
    
end

mse = nanmean((yh-y).^2, 1);

if nargin >= 7 && ~isempty(MAT_file)
    save(MAT_file, 'yh', 'mse', 'r', 'test_fold_indices');
end






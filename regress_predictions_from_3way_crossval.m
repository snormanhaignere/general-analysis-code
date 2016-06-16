function [yh, mse, r] = ...
    regress_predictions_from_3way_crossval(F, y, n_folds, method, K, varargin)

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
% n_folds = 10;
% [ls_yh, ls_mse] = ...
%     regress_predictions_from_3way_crossval(F, y, n_folds, 'least-squares');
% 
% % ridge
% [ridge_yh, ridge_mse] = ...
%     regress_predictions_from_3way_crossval(F, y, n_folds, 'ridge', 2.^(-30:30));
% 
% % compare MSE for least-squares and ridge
% figure;
% plot(ls_mse, ridge_mse, 'o');
% l = max([max(abs(xlim)), max(abs(ylim))]);
% xlim([0 l]); ylim([0 l]);
% hold on; plot([0 l], [0 l], 'r--');
% xlabel('Least Squares MSE'); ylabel('Estimated Weights');

% dimensions of feature matrix
[N,P] = size(F);

% check y is a column vector and dimensions match the feature matrix
assert(iscolumn(y) && length(y) == N);

% number of folds
if nargin < 3
    n_folds = N;
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

% divide features and data into folds
F_folds = create_folds(F, n_folds);
y_folds = create_folds(y, n_folds);

% calculate predictions
mse = nan(n_folds, 1);
r = nan(n_folds, 1);
yh_folds = cell(1, n_folds);
for test_fold = 1:n_folds
        
    % train and testing folds
    train_folds = setdiff(1:n_folds, test_fold);
    
    % concatenate training data
    F_train = cat(1, F_folds{train_folds});
    y_train = cat(1, y_folds{train_folds});
    
    
    % estimate regression weights using 2-way cross validation on training set
    B = regress_weights_from_2way_crossval(...
        F_train, y_train, n_folds-1, method, K, varargin{:});
    
    keyboard;
    
    % prediction from test features
    F_test = F_folds{test_fold};
    F_test = [ones(size(F_test, 1), 1), F_test]; %#ok<AGROW>
    yh_folds{test_fold} = F_test * B;
    
    % accuracy metrics
    err = yh_folds{test_fold} - y_folds{test_fold};
    mse(test_fold) = mean(err.^2, 1);
    r(test_fold) = corr(yh_folds{test_fold}, y_folds{test_fold});
    
end

yh = cat(1,yh_folds{:});






function [B, best_K, mse, r, mse_bestK] = ...
    regress_weights_from_2way_crossval(F, y, n_folds, method, K, varargin)

% [B, best_K, mse, r] = ...
%     regress_weights_from_2way_crossval(F, y, n_folds, method, K, varargin)
% 
% Estimates regression using N-fold cross-validation. Available methods include
% 'ridge', 'pls', and 'lasso'. The set of regularization parameters K 
% (e.g. lambda for ridge) can be specified. The parameters are varied and the
% weights for the parameter with the lowest cross-validated MSE are returned.
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
% n_folds = 10;
% [b, ~, ls_mse] = ...
%     regress_weights_from_2way_crossval(F, y, n_folds, 'least-squares');
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
%     n_folds = 10;
%     [b, best_K, mse] = ...
%         regress_weights_from_2way_crossval(F, y, n_folds, methods{i}, K);
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

% number of components to test
n_K = length(K);

% calculate predictions
mse = nan(n_folds, max(n_K,1));
r = nan(n_folds, max(n_K,1));
for test_fold = 1:n_folds
        
    % train and testing folds
    train_folds = setdiff(1:n_folds, test_fold);
    
    % concatenate training data
    F_train = cat(1, F_folds{train_folds});
    y_train = cat(1, y_folds{train_folds});
    
    % estimate weights from training data
    B = regress_weights(F_train, y_train, method, K, varargin{:});
    clear F_train y_train;
       
    % prediction from test features
    F_test = F_folds{test_fold};
    F_test = [ones(size(F_test, 1), 1), F_test]; %#ok<AGROW>
    yh = F_test * B;
    clear F_test B;
        
    % accuracy metrics
    err = bsxfun(@minus, yh, y_folds{test_fold});
    mse(test_fold,:) = mean(err.^2, 1);
    r(test_fold,:) = corr(yh, y_folds{test_fold});
    clear yh;
    
end

if strcmp(method, 'least-squares')
    best_K = [];
    mse_bestK = [];
else
    % best regularization value
    [~, best_K_index] = min( mean(mse, 1), [], 2 );
    best_K = K(best_K_index);
    mse_bestK = mean(mse(:, best_K_index));
    
    % check if the best regularizer is on the boundary
    if strcmp(method, 'ridge') && (best_K_index == 1 || best_K_index == n_K)
        warning('Best regularizer is on the boundary of possible values\nK=%f', best_K);
    elseif strcmp(method, 'pls') && best_K_index == n_K
        warning('Best regularizer is on the boundary of possible values\nK=%f', best_K);
    end
end

% estimate weights using all of the data
B = regress_weights(F, y, method, best_K, varargin{:});

function B = regress_weights(F, y, method, K, varargin)

[N, P] = size(F);
n_K = length(K);

% weights using all of the data
switch method
    case 'least-squares'
        B = pinv([ones(N,1), F]) * y;
    
    case 'ridge'
        B = ridge(y, F, K, 0, varargin{:});
        
    case 'pls'
        B = nan(P+1, n_K);
        for j = 1:n_K
            [~,~,~,~,B(:,j)] = plsregress(F, y, K(j), varargin{:});
        end
        
    case 'lasso'
        [B, S] = lasso(F, y, 'Lambda', K);
        B = [S.Intercept; B];
        
    otherwise
        error('No valid method for %s\n', method);
end
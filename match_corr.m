function Y = match_corr(X, corr_target, bounds)

% Takes in two vectors represented as a N x 2 matrix, and alters them to have a
% set correlation. The solution can be constrained by bounds to for example for
% the solution to be strictly positive for some variables. See example below. 
% 
% This code relies on functions in the Sound Texture Toolbox.
% 
% 
% % -- Example: Matching correlation --
% 
% % original signal
% X = randn(10,2);
% 
% % match
% Y = match_corr(X, 0.5);
% 
% % confirm correlation is matched
% clc;
% r_original = corr(X(:,1),X(:,2))
% r_match = corr(Y(:,1),Y(:,2))
% 
% % plot signals
% figure;
% subplot(1,2,1);
% plot(X); xlim([1, size(X,1)]);
% subplot(1,2,2);
% plot(Y); xlim([1, size(Y,1)]);
% 
% % -- Example: Positivity constraint on one variable --
% 
% % original signal
% X = randn(10,2);
% 
% % positivity constrain on the first variable
% bounds = [0, inf; -inf inf];
% Y = match_corr(X, 0.5, bounds);
% 
% % confirm correlation is matched
% clc;
% r_original = corr(X(:,1),X(:,2))
% r_match = corr(Y(:,1),Y(:,2))
% 
% % plot signals
% figure;
% subplot(1,2,1);
% plot(X); xlim([1, size(X,1)]);
% subplot(1,2,2);
% plot(Y); xlim([1, size(Y,1)]);


if nargin < 3
    bounds = [-inf, inf; -inf inf];
end

assert(size(X,2)==2);

% window of all ones
win = ones(size(X,1), 1);

% function and derivatives
func_handle = @(X)func_and_derivatives(X, win, corr_target);

if all(isinf(bounds(:))) % unconstrained
    
    % options for optimization
    options = optimoptions('fminunc','Algorithm','quasi-newton',...
        'GradObj','on','MaxIter',1e3,'Display','none',...
        'TolFun',1e-12,'TolX',1e-12);
    
    % run
    Y = fminunc(func_handle, X, options);
    
else % constrained
    
    % lower and upper bounds
    lower_bounds = nan(size(X));
    lower_bounds(:,1) = bounds(1,1);
    lower_bounds(:,2) = bounds(2,1);
    upper_bounds = nan(size(X));
    upper_bounds(:,1) = bounds(1,2);
    upper_bounds(:,2) = bounds(2,2);
    
    % options for constrained optimization
    options = optimoptions('fmincon','Algorithm','sqp',...
        'GradObj','on','MaxIter',1e3,'Display',...
        'none','TolFun',1e-12,'TolX',1e-12);
    
    % run optimization
    Y = fmincon(func_handle, X, [],[],[],[],...
        lower_bounds, upper_bounds, [], options); 
end

function [error, grad_error] = func_and_derivatives(X, win, corr_target)

corr_value = stat_corr_win(X(:,1), X(:,2), win);
error = (corr_value - corr_target).^2;

% gradient of correlation coefficient
grads_corr = [...
    grad_corr_win(X(:,1), X(:,2), corr_value, win), ...
    grad_corr_win(X(:,2), X(:,1), corr_value, win)];

% gradient of the error
grad_error = 2 * (corr_value - corr_target) * grads_corr;


function y = match_corr_single(x, ref, corr_target, bounds_x)

% Takes in two vectors x and ref and alters x so that the two variables have a
% particular correlation value. The solution can be constrained by bounds to for
% example for the solution to be strictly positive for some variables. See
% example below.
% 
% This code relies on functions in the Sound Texture Toolbox.
% 
% % -- Example: Matching correlation --
% 
% % original signal
% x = randn(10,1);
% ref = randn(10,1);
% 
% % match
% y = match_corr_single(x, ref, 0.5);
% 
% % confirm correlation is matched
% clc;
% r_original = corr(x,ref)
% r_match = corr(y,ref)
% 
% % plot signals
% figure;
% subplot(1,2,1);
% plot([x, ref]); xlim([1, size(X,1)]);
% subplot(1,2,2);
% plot([y, ref]); xlim([1, size(Y,1)]);
% 
% % -- Example: Positivity constraint --
% 
% % original signal
% x = randn(10,1);
% ref = randn(10,1);
% 
% % positivity constraint
% bounds = [0, inf];
% y = match_corr_single(x, ref, 0.5, bounds);
% 
% % confirm correlation is matched
% clc;
% r_original = corr(x,ref)
% r_match = corr(y,ref)
% 
% % plot signals
% figure;
% subplot(1,2,1);
% plot([x, ref]); xlim([1, size(X,1)]);
% subplot(1,2,2);
% plot([y, ref]); xlim([1, size(Y,1)]);

if nargin < 4
    bounds_x = [-inf inf];
end

assert(isvector(x) && isvector(ref));
x = x(:);
ref = ref(:);
assert(length(x) == length(ref));
assert(length(bounds_x)==2);

% window of all ones
win = ones(length(x), 1);

% function and derivatives
func_handle = @(x)func_and_derivatives(x, ref, win, corr_target);

if all(isinf(bounds_x)) % unconstrained
    
    % options for optimization
    options = optimoptions('fminunc','Algorithm','quasi-newton',...
        'GradObj','on','MaxIter',1e3,'Display','none',...
        'TolFun',1e-12,'TolX',1e-12);
    
    % run
    y = fminunc(func_handle, x, options);
    
else % constrained
    
    % lower and upper bounds
    lower_bounds = ones(size(x))*bounds_x(1);
    upper_bounds = ones(size(x))*bounds_x(2);
    
    % options for constrained optimization
    options = optimoptions('fmincon','Algorithm','sqp',...
        'GradObj','on','MaxIter',1e3,'Display',...
        'none','TolFun',1e-12,'TolX',1e-12);
    
    % run optimization
    y = fmincon(func_handle, x, [],[],[],[],...
        lower_bounds, upper_bounds, [], options); 
end

function [error, grad_error] = func_and_derivatives(x, ref, win, corr_target)

corr_value = stat_corr_win(x, ref, win);
error = (corr_value - corr_target).^2;

% gradient of correlation coefficient
grads_corr = grad_corr_win(x, ref, corr_value, win);

% gradient of the error
grad_error = 2 * (corr_value - corr_target) * grads_corr;


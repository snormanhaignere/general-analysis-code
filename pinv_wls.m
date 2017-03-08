function pinvX = pinv_wls(X,sig,orientation)
% function pinvX = pinv_wls(X,Y)
% 
% Returns a matrix similar to the pseudoinverse, useful for weighted-least-squares regression
% X is a [M x L] regression matrix.
% If M >= L, sig is a [M x 1] vector of errors in units of standard deviation.
% If L > 1, sig is a [L x 1] vector of errors.
% 
% Least-squares regression solution
% Bhat_ls = pinv(X)*y
% 
% Weighted least-squares regression solution
% Bhat_wls = pinv(X,sig)*y
% 
% See http://en.wikipedia.org/wiki/Least_squares#Weighted_least_squares
% 
% Example 1 (shows utility of wls-regression):
% X = randn(100,10); % [100 x 10] regression matrix
% B = randn(10,1); % [10 x 1] vector of weights
% sig = (rand(100,1)*5).^4; % [100 x 1] error distribution
% Y = X*B + sig .* randn(100,1);
% Bhat_ls = pinv(X)*Y;
% Bhat_wls = pinv_wls(X,sig)*Y;
% diag(corr(B,Bhat_ls))
% diag(corr(B,Bhat_wls))
% 
% Example 2 (transpose input matrix, transposes output matrix):
% X = randn(5,2);
% sig = rand(5,1);
% pinv_wls(X,sig)
% pinv_wls(X',sig)
% 
% Example 3 (with constant error variance, equivalent to pinv):
% X = randn(5,2);
% sig = 5*ones(5,1);
% pinv_wls(X,sig)
% pinv(X)

[M,L] = size(X);
% if max([M,L])~=length(sig)
%     error('Length of error vector (sig) should equal largest dimension of X');
% end
% 
% if size(sig,2) ~= 1
%     sig = transpose(sig);
% end
% 
% if size(sig,2) ~= 1
%     error('sig should be a vector of estimated standard deviations.');
% end

if nargin < 3
    if M >= L
        orientation = 1;
    else
        orientation = 2;
    end
end

if orientation == 1
    % weight matrix
    W = (1./sig) * ones(1,L);
    pinvX = pinv(W .* X) .* W';
elseif orientation == 2
    pinvX = pinv_wls(transpose(X),sig)';
else
    error('Orientation must be 1 or 2 not %d\n', orientation);
end
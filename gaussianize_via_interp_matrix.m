function [Y, f, finv] = gaussianize_via_interp_matrix(X, DIM)

% Applies gaussianization to a matrix of arbitrary size over a desired
% dimension. X is the matrix to gaussianize. f and finv are function handles
% that allow the same process to be applied to new data. Y = f(X)
% 
% -- Example -- 
% 
% % Generate kurtotic data
% X = randn(1000,3);
% for i = 1:3
%     X(:,i) = sign(X(:,i)) .* abs(X(:,i)).^(i+1);
% end
% 
% % Gaussianize
% [Y, f, finv] = gaussianize_via_interp_matrix(X, 1);
% 
% % plot
% figure;
% bins = linspace(-10,10,100);
% subplot(3,1,1);
% hist(X,bins);
% subplot(3,1,2);
% hist(f(X),100);
% subplot(3,1,3);
% hist(finv(f(X)),bins);

f = @(A)loop_over_mat(A, X, DIM, 0);
finv = @(A)loop_over_mat(A, X, DIM, 1);
Y = f(X);

function Y = loop_over_mat(A, X, DIM, flag)

% X - data from which to compute gaussizianization
% A - data to gaussianize
% DIM - dimension over which to compute the distribution
% flag - forward or inverse

% move desired dimension to the first dimension
perm_order = [DIM, setdiff(1:ndims(X), DIM)];
X = permute(X, perm_order);
A = permute(A, perm_order);

% unwrap columns
dimsX = size(X);
X = reshape(X, [dimsX(1), prod(dimsX(2:end))]);
dimsA = size(A);
A = reshape(A, [dimsA(1), prod(dimsA(2:end))]);
assert(all(dimsA(2:end) == dimsX(2:end)));

% gaussianize columns
Y = nan(size(A));
for i = 1:size(X,2)
    
    % gaussizination function handle or inverse
    if flag == 0 % gaussianize
        [~,f] = gaussianize_via_interp(X(:,i));
    elseif flag == 1; % inverse
        [~,~,f] = gaussianize_via_interp(X(:,i));
    else
        error('flag must be 1 or 2, not %d', flag);
    end
    
    % apply function handle
    Y(:,i) = f(A(:,i));
end

% re-wrap columns
Y = reshape(Y, dimsA);

% permute back
Y = ipermute(Y, perm_order);

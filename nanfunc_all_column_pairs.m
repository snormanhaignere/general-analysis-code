function C = nanfunc_all_column_pairs(func, A, B)

% Takes a function that takes 2 arguments and applies it to all pairs of columns
% 
% 2017-03-14: Created, Sam NH

if nargin < 3 || isempty(B);
    B = A;
end

% apply function
assert(ismatrix(A) && ismatrix(B));
C = nan(size(A,2), size(B,2));
for i = 1:size(A,2)
    for j = 1:size(B,2)
        xi = ~isnan(A(:,i)) & ~isnan(B(:,j));
        C(i,j) = func(A(xi,i), B(xi,j));
    end
end
clear xi;
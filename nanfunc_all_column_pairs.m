function C = nanfunc_all_column_pairs(func, A, B)

% Takes a function that takes 2 arguments and applies it to all pairs of columns
% 
% 2017-03-14: Created, Sam NH

B_present = nargin >=3 && ~isempty(B);

% apply function
assert(ismatrix(A));
n_cols = size(A,2);
C = nan(n_cols, n_cols);
for i = 1:n_cols
    for j = 1:n_cols
        if B_present
            xi = ~isnan(A(:,i)) & ~isnan(B(:,j));
            C(i,j) = func(A(xi,i), B(xi,j));
        else
            xi = ~isnan(A(:,i)) & ~isnan(A(:,j));
            C(i,j) = func(A(xi,i), A(xi,j));
        end
    end
end
clear xi;
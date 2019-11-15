function c = nanfunc_match_columns(func, A, B)

% Apply function func to corresponding columns of A and B, removing NaN
% values.
% 
% 2019-04-23: Created, Sam NH

assert(all(size(A) == size(B)));
c = nan(1,size(A,2));
for i = 1:size(A,2)
    xi = ~isnan(A(:,i)) & ~isnan(B(:,i));
    c(i) = func(A(xi,i), B(xi,i));
end
function C = nancorr_variance_sensitive(A, B)

% Measures variance sensitivite correlation to all pairs of columns of an input
% matrix A or all pairs of columns from input matrices A and B
% 
% 2017-03-15: Created by Sam NH

if nargin < 2
    B = [];
end

f = @corr_variance_sensitive_symmetric;
C = nanfunc_all_column_pairs(f, A, B);
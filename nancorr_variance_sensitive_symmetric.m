function C = nancorr_variance_sensitive_symmetric(A,B)

if nargin < 2
    B = [];
end

f = @corr_variance_sensitive_symmetric;
C = nanfunc_all_column_pairs(f, A, B);
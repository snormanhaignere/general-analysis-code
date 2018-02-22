function C = nancorr_normalized_squared_error(A,B)

if nargin < 2
    B = [];
end

f = @normalized_squared_error;
C = nanfunc_all_column_pairs(f, A, B);
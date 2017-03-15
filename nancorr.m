function C = nancorr(A, B)

% Wrapper for corr but excludes NaN values
%
% 2016-10-28: Created, Sam NH
% 
% 2017-03-14: Modified to rely on nanfunc_all_column_pairs
% 
% 2017-03-15: Slight change to make function structure more transparent

if nargin < 2
    B = [];
end

f = @corr;
C = nanfunc_all_column_pairs(f, A, B);
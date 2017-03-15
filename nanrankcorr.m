function C = nanrankcorr(A,B)

% Wrapper for rankcorr but excludes NaN values
%
% 2016-12-21: Created, Sam NH
% 
% 2017-03-14: Modified to rely on nanfunc_all_column_pairs
% 
% 2017-03-15: Slight change to make function structure more transparent

if nargin < 2
    B = [];
end

f = @rankcorr;
C = nanfunc_all_column_pairs(f, A, B);
function z = ge_tol(x, y, varargin)

% Tests whether x is greater than or equal to y up to some tolerance. 
% Uses dimension expansion (via bsxfun).
% 
% Default tolerance is 1e-10
% 
% Can specify alternative tolerance with 'tol', TOLERANCE

I.tol = 1e-10;
I = parse_optInputs_keyvalue(varargin, I);
z = bsxfun(@minus, x, y)>-I.tol;
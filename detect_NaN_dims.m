function Y = detect_NaN_dims(X, dims, varargin)

% Set dimensions that have any NaNs (or a fraction of NaNs above some
% threshold) to be entirely NaNs.
% 
% --- Example use -- 
% X = randn([2, 3, 4]);
% X(2,3,4) = NaN;
% detect_NaN_dims(X, 1)
% detect_NaN_dims(X, 2)
% detect_NaN_dims(X, 3)

% 2018-06-18: Created, Sam NH

I.frac_NaN = 0;
I = parse_optInputs_keyvalue(varargin, I);

% swap dimensions so that the dimensions over which to compute NaNs are at
% the end
N = size(X);
not_dims = setdiff(1:length(N), dims);
Xp = permute(X, [not_dims, dims]);
clear X;

% reshape to matrix
Xr = reshape(Xp, [prod(N(not_dims)), prod(N(dims))]);
clear Xp

% set columns with NaNs to zero
xi = mean(isnan(Xr),1) > I.frac_NaN;
Yr = Xr;
Yr(:,xi) = NaN;
clear Xr;

% undo the reshaping and permutations transformations
Yp = reshape(Yr, [N(not_dims), N(dims)]);
Y = ipermute(Yp, [not_dims, dims]);





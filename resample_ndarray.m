function X = resample_ndarray(X, new_sr, old_sr, DIM)
% Wrapper function for the resample function that works for nd-arrays operating over the first
% dimension.
% 
% 2017-06-30: Modified to accept the dimension over which to resample

if nargin < 4
    DIM = 1;
end

% permute chosen dimsnion to front;
perm_order = [DIM, setdiff(1:ndims(X), DIM)];
X = permute(X, perm_order);

% resample
X = resamp_first_dim(X, new_sr, old_sr);

% permute back
X = ipermute(X, perm_order);

function Y = resamp_first_dim(X, new_sr, old_sr)

dims = size(X);
X = reshape(X, [dims(1),prod(dims(2:end))]);
Y = resample(X, new_sr, old_sr);
Y = reshape(Y, [size(Y,1), dims(2:end)]);
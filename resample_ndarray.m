function Y = resample_ndarray(X, new_sr, old_sr)
% Wrapper function for the resample function that works for nd-arrays operating over the first
% dimension.

dims = size(X);
X = reshape(X, [dims(1),prod(dims(2:end))]);
Y = resample(X, new_sr, old_sr);
Y = reshape(Y, [size(Y,1), dims(2:end)]);
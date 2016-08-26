function X = squeeze_dims(X, DIMS)

% Remove specified singleton dimensions from array X. Safer than squeeze because
% only the specified dimensions are removed.
% 
% -- Example --
% X = randn(3,1,1,4);
% size(squeeze(X))
% size(squeeze_dims(X,2))
% size(squeeze_dims(X,[2 3]))
% squeeze(X)
% squeeze_dims(X,[2 3])

dimsize = [size(X),1];
assert(all(dimsize(DIMS) == 1));
dimsize(DIMS) = [];
X = reshape(X, dimsize);

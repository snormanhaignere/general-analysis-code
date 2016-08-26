function inds = subdivide(N, n_divisions)

% Returns indices that subdivide a vector of length N into sections of
% approximately equal length (exactly equal if n_divisions exactly subdivides N).
% 
% -- Example --
% 
% subdivide(10,4)
%
% 2016-06-25: Created by Sam NH


% size of each fold
fold_sizes = floor(N/n_divisions) * ones(1, n_divisions);
fold_sizes(1 : rem(N,n_divisions)) = fold_sizes(1 : rem(N,n_divisions)) + 1;
assert(sum(fold_sizes) == N);

% indices for each fold
inds = nan(1,N);
for i = 1:n_divisions
    xi = (1:fold_sizes(i)) + sum(fold_sizes(1:i-1));
    inds(xi) = i;
end